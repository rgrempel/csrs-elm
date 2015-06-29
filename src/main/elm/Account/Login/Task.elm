module Account.Login.Task where

import Task exposing (Task)
import Http exposing (RawError, Response, url, send, defaultSettings, string, uriEncode)
import List exposing (foldl)
import Account.Login.Model exposing (Credentials)
import Http.Csrf exposing (withCsrf)
import Http.CacheBuster exposing (withCacheBuster)


attemptLoginTask : Credentials -> Task RawError Response 
attemptLoginTask credentials =
    let
        params =
            foldl
                ( \iter accum -> accum ++ iter ++ "&" )
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
