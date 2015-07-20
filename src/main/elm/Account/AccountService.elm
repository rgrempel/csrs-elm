module Account.AccountService where

import List exposing (foldl, foldr, intersperse)
import Http exposing (uriEncode, url, string, defaultSettings, fromJson, Settings, Request, Response, Error(BadResponse), RawError(RawTimeout, RawNetworkError))
import Signal exposing (Mailbox, Address, mailbox)
import Task exposing (Task, map, mapError, succeed, fail, onError, andThen, toResult)
import Language.LanguageService as LanguageService exposing (Language(..)) 
import Http.Csrf exposing (withCsrf)
import Http.CacheBuster exposing (withCacheBuster)
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import String exposing (toUpper)


type LoginError
    = LoginWrongPassword  -- 401
    | LoginWrongCsrf      -- 403
    | LoginHttpError Http.Error

type Action
    = SetCurrentUser (Maybe User)
    | NoOp

type alias Credentials =
    { username: String
    , password: String
    , rememberMe: Bool
    }

type Role
    = RoleUser
    | RoleAdmin


roleDecoder : JD.Decoder Role
roleDecoder =
    JD.string `JD.andThen` \s ->
        case (toUpper s) of
            "ROLE_ADMIN" ->
                JD.succeed RoleAdmin

            "ROLE_USER" ->
                JD.succeed RoleUser

            _ ->
                JD.fail <| s ++ " is not a role I recognize"


type alias User =
    { login : String
    , langKey: Language
    , roles: Maybe (List Role) 
    }


userDecoder : JD.Decoder User
userDecoder =
    let
        withRoles =
            JD.object3 User
                ("login" := JD.string)
                ("langKey" := LanguageService.decoder)
                ("roles" := JD.maybe (JD.list roleDecoder))

        withoutRoles =
            JD.object3 User
                ("login" := JD.string)
                ("langKey" := LanguageService.decoder)
                (JD.succeed Nothing)

    in
        JD.oneOf [withRoles, withoutRoles]


type alias Model m =
    { m 
        | currentUser : Maybe User
    }


init : m -> Model m
init model = Model Nothing model


actions : Mailbox Action
actions = mailbox NoOp 


do : Action -> Task x ()
do = Signal.send actions.address


tasks : Signal (Maybe (Task () ()))
tasks = Signal.map reaction (.signal actions)
    

update : Action -> Model m -> Model m
update action model =
    case action of
        SetCurrentUser user ->
            @currentUser user model

        _ ->
            model


reaction : Action -> Maybe (Task () ())
reaction action =
    case action of
        SetCurrentUser user ->
            Maybe.map
                (LanguageService.do << LanguageService.SwitchLanguage << .langKey)
                (user)
        
        _ ->
            Nothing


send : Request -> Task RawError Response
send = (withCacheBuster (withCsrf Http.send)) defaultSettings


attemptLogin : Credentials -> Task LoginError (Maybe User) 
attemptLogin credentials =
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

        handleResponse response =
            case response.status of
                200 -> fetchCurrentUser |> mapError LoginHttpError
                401 -> fail LoginWrongPassword
                403 -> fail LoginWrongCsrf
                _ -> fail <| LoginHttpError (Http.BadResponse response.status response.statusText)

    in
        (send request |> mapError (promoteError >> LoginHttpError))
        `andThen` handleResponse
        

promoteError : RawError -> Error
promoteError error =
    case error of
        Http.RawTimeout -> Http.Timeout
        Http.RawNetworkError -> Http.NetworkError


attemptLogout : Task Error (Maybe User)
attemptLogout =
    (send
        { verb = "POST"
        , headers = []
        , url = url "/api/logout" []
        , body = Http.empty
        }
    |> mapError promoteError)
    `andThen` always (fetchCurrentUser)


fetchCurrentUser : Task Http.Error (Maybe User) 
fetchCurrentUser =
    Http.fromJson userDecoder (
        send
            { verb = "GET"
            , headers = []
            , url = url "/api/account" []
            , body = Http.empty
            }
    ) `andThen` (\user ->
        (do <| SetCurrentUser (Just user)) |> map (always (Just user))
    ) `onError` (\error ->
        case error of
            BadResponse 401 _ ->
                -- This is actually success ... it just means that the user
                -- is not logged int.
                (do <| SetCurrentUser Nothing) |> map (always Nothing)

            _ ->
                fail error
    )


sendInvitation : Bool -> String -> Language -> Task Http.Error ()
sendInvitation resetPassword email language =
    send
        { verb = "POST"
        , headers =
            [ ("Content-Type", "application/json")
            , ("Accept", "application/json")
            ]
        , url =
            url "/api/invitation/account"
                [ ("passwordReset", if resetPassword then "true" else "false")
                ]
        , body =
            Http.string <|
                JE.encode 0 <|
                    JE.object
                        [ ("email", JE.string email)
                        , ("langKey", LanguageService.encode language)
                        ]
        }
    |> mapError promoteError
    |> map (always ())


sendInvitationToCreateAccount : String -> Language -> Task Http.Error ()
sendInvitationToCreateAccount = sendInvitation False


sendInvitationToResetPassword : String -> Language -> Task Http.Error ()
sendInvitationToResetPassword = sendInvitation True


type alias UserEmailActivation =
    { id : Int
    , userEmail : UserEmail
    , activationKey : String
    }

userEmailActivationDecoder : JD.Decoder UserEmailActivation
userEmailActivationDecoder =
    JD.object3 UserEmailActivation
        ("id" := JD.int)
        ("userEmail" := userEmailDecoder)
        ("activationKey" := JD.string)

type alias UserEmail =
    { id : Int
    , email : Email
    , user : Maybe User
    }

userEmailDecoder : JD.Decoder UserEmail
userEmailDecoder =
    JD.object3 UserEmail
        ("id" := JD.int)
        ("email" := emailDecoder)
        ("user" := JD.maybe userDecoder)

type alias Email =
    { id : Int
    , emailAddress : String
    }

emailDecoder : JD.Decoder Email
emailDecoder =
    JD.object2 Email
        ("id" := JD.int)
        ("emailAddress" := JD.string)


fetchInvitation : String -> Task Http.Error UserEmailActivation 
fetchInvitation key =
    Http.fromJson userEmailActivationDecoder (
        send
            { verb = "GET"
            , headers =
                [ ("Accept", "application/json")
                ]
            , url = url ("/api/invitation/" ++ key) []
            , body = Http.empty
            }
    )

    
