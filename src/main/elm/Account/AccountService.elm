module Account.AccountService where

import AppTypes exposing (..)
import Account.AccountServiceTypes exposing (..)
import Language.LanguageTypes as LanguageTypes exposing (Language(..)) 

import Http exposing (uriEncode, url, string, defaultSettings, fromJson, Settings, Request, Response, Error(BadResponse), RawError(RawTimeout, RawNetworkError))
import Task exposing (Task, map, mapError, succeed, fail, onError, andThen, toResult)
import Http.Csrf exposing (withCsrf)
import Http.CacheBuster exposing (withCacheBuster)
import Json.Encode as JE
import String exposing (join)


update : Action -> Model -> Model
update action model =
    case action of
        SetCurrentUser user ->
            {model | currentUser <- user}

        _ ->
            model


reaction : Action -> Maybe (Task () ())
reaction action =
    case action of
        SetCurrentUser user ->
            Maybe.map
                (LanguageTypes.do << LanguageTypes.SwitchLanguage << .langKey)
                (user)
        
        _ ->
            Nothing


send : Request -> Task RawError Response
send = (withCacheBuster (withCsrf Http.send)) defaultSettings


attemptLogin : Credentials -> Task LoginError (Maybe User) 
attemptLogin credentials =
    let
        params =
            join "&"
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


initialTask : Task Http.Error (Maybe User)
initialTask = fetchCurrentUser


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
                        , ("langKey", LanguageTypes.encode language)
                        ]
        }
    |> mapError promoteError
    |> map (always ())


sendInvitationToCreateAccount : String -> Language -> Task Http.Error ()
sendInvitationToCreateAccount = sendInvitation False


sendInvitationToResetPassword : String -> Language -> Task Http.Error ()
sendInvitationToResetPassword = sendInvitation True


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

    
