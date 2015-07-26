module Http.CacheBuster where

import Http exposing (Settings, Request, RawError, Response, send)
import Task exposing (Task, andThen)
import TaskTutorial exposing (getCurrentTime)
import Time exposing (Time)
import String exposing (contains, endsWith)


addCacheBuster : Time -> String -> String
addCacheBuster time url =
    -- essentially, we want to add ?cacheBuster=123482
    -- or, &cacheBuster=123482
    let
        urlWithQueryIndicator =
            if contains "?" url then url else url ++ "?"
        
        urlWithParamSeparator =
            if endsWith "?" urlWithQueryIndicator 
               then urlWithQueryIndicator
               else urlWithQueryIndicator ++ "&"

    in
        urlWithParamSeparator ++ "cacheBuster=" ++ (toString time)


withCacheBuster : (Settings -> Request -> Task RawError Response) -> Settings -> Request -> Task RawError Response
withCacheBuster func settings request =
    let
        funcWithTime time =
            func settings 
                { request |
                    url <- addCacheBuster time request.url
                }

    in
        getCurrentTime `andThen` funcWithTime
