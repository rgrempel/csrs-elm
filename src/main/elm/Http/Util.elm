module Http.Util where

import Http.Csrf exposing (withCsrf)
import Http.Decorators exposing (addCacheBuster, interpretStatus)
import Task exposing (Task)
import Http exposing (Request, RawError, Error, Response, defaultSettings)


send : Request -> Task Error Response
send = interpretStatus << sendRaw


sendRaw : Request -> Task RawError Response
sendRaw = addCacheBuster (withCsrf Http.send) defaultSettings


