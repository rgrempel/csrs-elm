module Account.AccountService where

import List exposing (foldl, foldr, intersperse)
import Http exposing (uriEncode, url, string, send, defaultSettings, Response, RawError(RawTimeout, RawNetworkError))
import Signal exposing (Mailbox, Address, mailbox)
import Task exposing (Task, succeed, fail, onError, andThen, toResult)
import Http.Csrf exposing (withCsrf)
import Http.CacheBuster exposing (withCacheBuster)

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
    | NoOp

type alias Credentials =
    { username: String
    , password: String
    , rememberMe: Bool
    }


service : Mailbox (Action a)
service = mailbox NoOp 


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


action2task : Action a -> Maybe (Task () ())
action2task action =
    case action of
        AttemptLogin credentials callback ->
            Just <|
                toResult (attemptLoginTask credentials)
                `andThen`
                (handleLoginCallback callback)
 
        _ ->
            Nothing


attemptLoginTask : Credentials -> Task RawError Response 
attemptLoginTask credentials =
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
        (withCacheBuster (withCsrf send)) defaultSettings request


