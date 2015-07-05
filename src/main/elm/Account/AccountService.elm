module Account.AccountService where

import List exposing (foldl)
import Http exposing (uriEncode, url, string, send, defaultSettings, Response, RawError)
import Signal exposing (Address, Mailbox, mailbox)
import Task exposing (Task)

import Http.Csrf exposing (withCsrf)
import Http.CacheBuster exposing (withCacheBuster)

type Action
    = AttemptLogin Credentials
    | NoOp

type alias Credentials =
    { username: String
    , password: String
    , rememberMe: Bool
    }


service : Mailbox Action
service = mailbox NoOp 


action2task : Action -> Maybe (Task () ())
action2task action =
    case action of
        AttemptLogin credentials ->
            Just <| 
                Task.map (always ()) <|
                    Task.mapError (always ()) <|
                        (attemptLoginTask credentials) 

        _ ->
            Nothing


attemptLoginTask : Credentials -> Task RawError Response 
attemptLoginTask credentials =
    let
        params =
            foldl
                ( \iter accum -> accum ++ if accum == "" then iter else "&" ++ iter )
                ""
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


