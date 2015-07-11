module Account.AccountService where

import List exposing (foldl, foldr, intersperse)
import Http exposing (uriEncode, url, string, defaultSettings, fromJson, Settings, Request, Response, Error(BadResponse), RawError(RawTimeout, RawNetworkError))
import Signal exposing (Mailbox, Address, mailbox)
import Task exposing (Task, succeed, fail, onError, andThen, toResult)
import Language.LanguageService as LanguageService exposing (Language(..)) 
import Http.Csrf exposing (withCsrf)
import Http.CacheBuster exposing (withCacheBuster)
import Json.Decode as JD exposing ((:=))


type LoginResult
    = Success        -- 200
    | WrongPassword  -- 401
    | WrongCsrf      -- 403
    | Other Int String
    | Timeout
    | NetworkError

type alias LoginCallback a =
    Maybe (Address a, LoginResult -> a)

type Action a
    = AttemptLogin Credentials (LoginCallback a)
    | FetchCurrentUser
    | SetCurrentUser (Maybe User)
    | NoOp

type alias Credentials =
    { username: String
    , password: String
    , rememberMe: Bool
    }

type alias User =
    { login : String
    , langKey: Language
    , roles: List String
    }


userDecoder : JD.Decoder User
userDecoder =
    JD.object3 User
        ("login" := JD.string)
        ("langKey" := LanguageService.decoder)
        ("roles" := JD.list JD.string)


type alias Model m =
    { m 
        | currentUser : Maybe User
    }


init : m -> Model m
init model = Model Nothing model


actions : Mailbox (Action a)
actions = mailbox NoOp 


do : Action a -> Task x ()
do = Signal.send actions.address


tasks : Signal (Maybe (Task () ()))
tasks = Signal.map reaction (.signal actions)
    

update : Action a -> Model m -> Model m
update action model =
    case action of
        SetCurrentUser user ->
            @currentUser user model

        _ ->
            model


reaction : Action a -> Maybe (Task () ())
reaction action =
    case action of
        AttemptLogin credentials callback ->
            Just <| attemptLoginTask credentials callback

        FetchCurrentUser ->
            Just fetchCurrentUserTask

        _ ->
            Nothing


send : Request -> Task RawError Response
send = (withCacheBuster (withCsrf Http.send)) defaultSettings


handleLoginCallback : LoginCallback a -> Result RawError Response -> Task x ()
handleLoginCallback callback result =
    case callback of
        Just (address, func) ->
            Signal.send address << func <|
                case result of
                    Ok response ->
                        case response.status of
                            200 -> Success
                            401 -> WrongPassword
                            403 -> WrongCsrf
                            _ -> Other response.status response.statusText

                    Err error ->
                        case error of
                            RawTimeout -> Timeout
                            RawNetworkError -> NetworkError

        _ ->
            succeed ()


attemptLoginTask : Credentials -> LoginCallback a -> Task x () 
attemptLoginTask credentials callback =
    let
        params =
            foldr (++) "" <| intersperse "&"
                [ "j_username=" ++ uriEncode(credentials.username)
                , "j_password=" ++ uriEncode(credentials.password)
                , "remember-me=" ++ ( if credentials.rememberMe then "true" else "false" )
                ]

        request =
            { verb = "POST"
            , headers =
                [ ("Content-Type", "application/x-www-form-urlencoded")
                ]
            , url = url "/api/authentication" [] 
            , body = string params
            }

    in
        toResult (send request)
        `andThen` \result ->
            toResult (do FetchCurrentUser)
            `andThen`
            always (handleLoginCallback callback result)


fetchCurrentUserTask : Task () () 
fetchCurrentUserTask =
    Http.fromJson userDecoder (
        send
            { verb = "GET"
            , headers = []
            , url = url "/api/account" []
            , body = Http.empty
            }
    ) `andThen` (\user ->
        do <| SetCurrentUser (Just user)
    ) `onError` (\error ->
        case error of
            BadResponse 401 _ ->
                do <| SetCurrentUser Nothing

            -- Other bad responses?
            -- NetworkError
            -- UnexpectedPayload String
            _ ->
                -- Should have some facility for 'generic' errors
                Task.succeed ()
    )
