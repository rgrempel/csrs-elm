module Http.Csrf where

import Http exposing (Settings, Request, RawError, Response, send)
import Task exposing (Task, andThen)
import Dict exposing (get)
import Cookies


csrfCookie : String
csrfCookie = "CSRF-TOKEN"


csrfHeader : String
csrfHeader = "X-CSRF-TOKEN"


withCsrf : (Settings -> Request -> Task RawError Response) -> Settings -> Request -> Task RawError Response
withCsrf func settings request =
    let
        funcWithCookies cookies =
            case get csrfCookie cookies of
                Just token ->
                    func settings
                        { request |
                            headers <- (csrfHeader, token) :: request.headers
                        }

                _ ->
                    func settings request

    in
        Cookies.get `andThen` funcWithCookies

