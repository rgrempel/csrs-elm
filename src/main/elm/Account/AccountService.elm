module Account.AccountService where

import AppTypes exposing (..)
import Account.AccountServiceTypes exposing (..)
import Language.LanguageTypes as LanguageTypes exposing (Language(..)) 

import Http exposing (uriEncode, url, string, defaultSettings, fromJson, Settings, Request, Response, Error(BadResponse), RawError(RawTimeout, RawNetworkError))
import Task exposing (Task, map, mapError, succeed, fail, onError, andThen, toResult)
import Task.Util exposing (ignore)
import Http.Csrf exposing (withCsrf)
import Http.Decorators exposing (addCacheBuster, interpretStatus)
import Json.Encode as JE
import Json.Decode as JD
import String exposing (join)


submodule : SubModule x (AccountModel x) Action
submodule =
    { initialModel = initialModel
    , actions = .signal actions
    , update = update
    , reaction = Just reaction
    , initialTask = Just <| ignore fetchCurrentUser 
    }


update : Action -> AccountModel x -> AccountModel x
update action model =
    case action of
        SetCurrentUser user ->
            {model | currentUser <- user}

        _ ->
            model


reaction : Action -> AccountModel x -> Maybe (Task () ())
reaction action model =
    case action of
        SetCurrentUser user ->
            Maybe.map
                (LanguageTypes.do << LanguageTypes.SwitchLanguage << .langKey)
                (user)
        
        _ ->
            Nothing


send : Request -> Task Error Response
send = interpretStatus << sendRaw


sendRaw : Request -> Task RawError Response
sendRaw = addCacheBuster (withCsrf Http.send) defaultSettings


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

        handleError error =
            case error of
                BadResponse 401 _ -> LoginWrongPassword
                _ -> LoginHttpError error

    in
        mapError handleError
            (send request)
                `andThen` always (fetchCurrentUser |> mapError LoginHttpError)
        

createAccount : CreateAccountInfo -> Task CreateAccountError ()
createAccount info =
    let
        request =
            { verb = "POST"
            , headers =
                [ ("Content-Type", "application/json")
                ]
            , url = url "/api/register" [ ("key", info.activationKey) ]
            , body =
                Http.string <|
                    JE.encode 0 <|
                        JE.object
                            [ ("login", JE.string info.username)
                            , ("password", JE.string info.password)
                            , ("langKey", LanguageTypes.encode info.language)
                            ]
            }

        handleError error =
            case error of
                BadResponse 400 _ -> UserAlreadyExists info.username 
                _ -> CreateAccountHttpError error

    in
        mapError handleError <|
            map (always ()) <|
                send request


resetPassword : String -> String -> Task Error ()
resetPassword password key =
    map (always ()) <|
        send
            { verb = "POST"
            , headers =
                [ ("Content-Type", "application/json")
                ]
            , url = url "/api/reset_password" []
            , body =
                Http.string <|
                    JE.encode 0 <|
                        JE.object
                            [ ("key", JE.string key)
                            , ("newPassword", JE.string password)
                            ]
            }


changePassword : String -> String -> Task LoginError ()
changePassword old new =
    let
        request =
            { verb = "POST"
            , headers =
                [ ("Content-Type", "application/json")
                ]
            , url = url "/api/account/change_password" []
            , body =
                Http.string <|
                    JE.encode 0 <|
                        JE.object
                            [ ("oldPassword", JE.string old)
                            , ("newPassword", JE.string new)
                            ]
            }

        handleError error =
            case error of
                BadResponse 403 _ -> LoginWrongPassword
                _ -> LoginHttpError error

    in
        mapError handleError <|
            map (always ()) <|
                send request


attemptLogout : Task Error (Maybe User)
attemptLogout =
    send 
        { verb = "POST"
        , headers = []
        , url = url "/api/logout" []
        , body = Http.empty
        }
    `andThen` always fetchCurrentUser


fetchCurrentUser : Task Http.Error (Maybe User) 
fetchCurrentUser =
    Http.fromJson userDecoder (
        sendRaw 
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
                -- is not logged in.
                (do <| SetCurrentUser Nothing) |> map (always Nothing)

            _ ->
                fail error
    )


sendInvitation : Bool -> String -> Language -> Task Http.Error ()
sendInvitation resetPassword email language =
    always () `map`
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


sendInvitationToCreateAccount : String -> Language -> Task Http.Error ()
sendInvitationToCreateAccount = sendInvitation False


sendInvitationToResetPassword : String -> Language -> Task Http.Error ()
sendInvitationToResetPassword = sendInvitation True


fetchInvitation : String -> Task Http.Error UserEmailActivation 
fetchInvitation key =
    Http.fromJson userEmailActivationDecoder <|
        sendRaw
            { verb = "GET"
            , headers =
                [ ("Accept", "application/json")
                ]
            , url = url ("/api/invitation/" ++ key) []
            , body = Http.empty
            }


allSessions : Task Http.Error (List Session)
allSessions =
    Http.fromJson (JD.list sessionDecoder) <|
        sendRaw
            { verb = "GET"
            , headers =
                [ ("Accept", "application/json")
                ]
            , url = url "/api/account/sessions" []
            , body = Http.empty
            }


deleteSession : Session -> Task Http.Error Session
deleteSession session =
    always session `map`
        send 
            { verb = "DELETE"
            , headers = []
            , url = url ("/api/account/sessions/" ++ session.series) []
            , body = Http.empty
            }


userExists : String -> Task Http.Error Bool
userExists user =
    always True `map`
        send
            { verb = "HEAD"
            , headers = []
            , url = url ("/api/users/" ++ user) []
            , body = Http.empty
            }
        `onError` \error ->
            -- This is actually success ... it just means that the user wasn't
            -- found, so we report that on the success path.
            case error of
                BadResponse 404 _ -> succeed False
                _ -> fail error
