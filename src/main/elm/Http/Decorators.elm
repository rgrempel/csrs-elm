module Http.Decorators (addCacheBuster, promoteError, interpretStatus) where

{-| This module supplies several functions which you can use to decorate
`Http.send` in order to create a function with additional behaviour. You can
apply the decorators to individual uses of `Http.send` -- for example:

    addCacheBuster Http.send Http.defaultSettings
        { verb = "GET"
        , headers = []
        , url = Http.url "/api/account" []
        , body = Http.empty
        }

Alternatively, you can compose a decorated function and use it repeatedly, e.g.

    specialSend : Settings -> Request -> Task RawError Response
    specialSend = addCacheBuster Http.send

The definition of something like `specialSend` is left for client code, so that
you can mix and match whichever decorators you need. You could conceivably also
want to partially apply `Http.defaultSettings` (or your own defaultSettings).
Thus, one combination which can be useful is as follows:

    verySpecialSend : Request -> Task Error Response
    verySpecialSend = interpretStatus << addCacheBuster Http.send Http.defaultSettings

You could then call `verySpecialSend` like this:

    verySpecialSend
        { verb = "GET"
        , headers = []
        , url = Http.url "/api/account" []
        , body = Http.empty
        }

... and, of course, you could still provide an `andThen`, `map`, `mapError`, `onError` etc.
to do any further work that might be needed with the Http.Error or Http.Result.

Alternatively, if the `Settings` need to vary at each call-site, you can do something
like this:

    lessSpecialSend : Settings -> Request -> Task Error Response
    lessSpecialSend settings = interpretStatus << addCacheBuster Http.send settings

Note that some of this is redundant if you are using `Http.fromJson` anyway, since
`Http.fromJson` already does the equivalent of `promoteError` and `interpretStatus`.

@docs addCacheBuster, promoteError, interpretStatus
-}


import Http exposing (Settings, Request, RawError(..), Error(..), Response, send)
import Task exposing (Task, andThen, mapError, succeed, fail)
import TaskTutorial exposing (getCurrentTime)
import String exposing (contains, endsWith)


{- Public API -}

{-| Decorates `Http.send` so that a 'cache busting' parameter will always be
added to the URL -- e.g. '?cacheBuster=219384729384', where the number is
derived from the current time.  The purpose of doing this would be to help
defeat any caching that might otherwise take place at some point between the
client and server.
-}
addCacheBuster : (Settings -> Request -> Task RawError Response) -> (Settings -> Request -> Task RawError Response)
addCacheBuster func settings request =
    let
        sendWithTime time =
            func settings
                { request | url <- urlWithTime time }

        urlWithTime time =
            -- essentially, we want to add ?cacheBuster=123482
            -- or, &cacheBuster=123482
            urlWithParamSeparator ++ "cacheBuster=" ++ (toString time)

        urlWithParamSeparator =
            if endsWith "?" urlWithQueryIndicator
               then urlWithQueryIndicator
               else urlWithQueryIndicator ++ "&"

        urlWithQueryIndicator =
            if contains "?" request.url
                then request.url
                else request.url ++ "?"

    in
        getCurrentTime `andThen` sendWithTime


{-| Decorates the result of `Http.send` so that the error type is `Http.Error`
rather than `Http.RawError`. This may be useful in cases where you are not
using `Http.fromJson`, and your API prefers to deal with `Http.Error` rather
than `Http.RawError`.

Pay attention to return types when composing this decorator with other
decorators.  For intance, if used in conjunction with `addCacheBuster`, you
would need to apply `addCacheBuster` first.  E.g.

    -- Good
    promoteError << addCacheBuster Http.send Http.defaultSettings

    -- Bad
    addCacheBuster promoteError << Http.send Http.defaultSettings
-}
promoteError : Task RawError Response -> Task Error Response
promoteError task =
    let
        promote error =
            case error of
                RawTimeout -> Timeout
                RawNetworkError -> NetworkError

    in
        mapError promote task


{-| Decorates the result of `Http.send` so that responses with a status code
which is outside of the 2XX range are processed as `BadResponse` errors (to be
further handled via `Task.onError` or `Task.mapError` etc.), rather than as
successful responses (to be further handled by `Task.andThen` or `Task.map`
etc.).  This may be useful in cases where you are not using `Http.fromJson` and
you do not need to distinguish amongst different types of successful status
code.

Note that this automatically also applies `promoteError`, so you do not need to
apply that decorator as well.
-}
interpretStatus : Task RawError Response -> Task Error Response
interpretStatus task =
    let
        handleResponse response =
            if response.status >= 200 && response.status < 300
                then succeed response
                else fail (BadResponse response.status response.statusText)

    in
        promoteError task `andThen` handleResponse
