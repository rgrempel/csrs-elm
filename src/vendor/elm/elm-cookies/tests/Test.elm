module Test where

import String
import Graphics.Element exposing (Element)
import Signal exposing (Signal, Mailbox, mailbox, constant, send)
import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)
import ElmTest.Runner.Element exposing (runDisplay)
import Task exposing (Task, andThen, sequence, map)
import Date exposing (fromTime)
import Time exposing (second)
import Dict

import Cookies


main : Signal Element
main = 
    Signal.map runDisplay tests.signal


tests : Mailbox Test
tests =
    mailbox (suite "Cookies" [])


port tasks : Signal (Task x ())
port tasks =
    Signal.constant <|
        sequence
            [ simpleSetGet
            , secondSetGet
            , multipleSetGet
            , encodingTest
            , setWithWrongPath
            , setWithGoodPath
            , maxAgeFuture
            , expiresInFuture
            , expiresInPast
            ]
        `andThen`
        (send tests.address << suite "Cookies")


(>>>) = flip Task.map
(>>+) = Task.andThen

simpleSetGet : Task x Test
simpleSetGet =
    (Cookies.set "bog" "joe" >>+ always Cookies.get)
    >>>
    (Dict.get "bog" >> assertEqual (Just "joe") >> test "simple set then get")


-- Make sure we're actually *changing* the cookie
secondSetGet : Task x Test
secondSetGet =
    (Cookies.set "bog" "frank" >>+ always Cookies.get)
    >>>
    (Dict.get "bog" >> assertEqual (Just "frank") >> test "repeated set/get, to make sure we can change the cookie")


multipleSetGet : Task x Test
multipleSetGet =
    (
        Cookies.set "cookie1" "cookie 1 value" 
        >>+
        always (Cookies.set "cookie2" "cookie 2 value")
        >>+
        always Cookies.get
    )
    >>>
    (λcookies ->
        [Dict.get "cookie1" cookies, Dict.get "cookie2" cookies] |>
        assertEqual [Just "cookie 1 value", Just "cookie 2 value"] |>
        test "multiple cookies")


encodingTest : Task x Test
encodingTest =
    (Cookies.set "encoded=" "value needs encoding ;" >>+ always Cookies.get)
    >>>
    (Dict.get "encoded=" >> assertEqual (Just "value needs encoding ;") >> test "key and value should be encoded")


setWithWrongPath : Task x Test
setWithWrongPath =
    let
        defaults =
            Cookies.defaultOptions

        options =
            { defaults | path <- Just "/path" }

    in
        (Cookies.setWithOptions options "wrong path cookie" "path cookie value" >>+ always Cookies.get)
        >>>
        (Dict.get "wrong path cookie" >> assertEqual Nothing >> test "test with path set to bad value")


setWithGoodPath : Task x Test
setWithGoodPath =
    let
        defaults =
            Cookies.defaultOptions

        options =
            { defaults | path <- Just "/" }

    in
        (Cookies.setWithOptions options "good path cookie" "path cookie value" >>+ always Cookies.get)
        >>>
        (Dict.get "good path cookie" >> assertEqual (Just "path cookie value") >> test "test with path set to good value")


maxAgeFuture : Task x Test
maxAgeFuture =
    let
        defaults =
            Cookies.defaultOptions

        options =
            { defaults | maxAge <- Just 1000 }

    in
        (Cookies.setWithOptions options "max age future" "cookie value" >>+ always Cookies.get)
        >>>
        (Dict.get "max age future" >> assertEqual (Just "cookie value") >> test "test with maxAge in future")


expiresInFuture : Task x Test
expiresInFuture =
    let
        defaults =
            Cookies.defaultOptions

        options =
            -- Sets the date to September 26, 2028 conveniently
            { defaults | expires <- Just (fromTime (1853609409 * second)) }

    in
        (Cookies.setWithOptions options "expires" "cookie value" >>+ always Cookies.get)
        >>>
        (Dict.get "expires" >> assertEqual (Just "cookie value") >> test "test with expiry in future")


expiresInPast : Task x Test
expiresInPast =
    let
        defaults =
            Cookies.defaultOptions

        options =
            { defaults | expires <- Just (fromTime 0) }

    in
        (Cookies.setWithOptions options "expires" "cookie value" >>+ always Cookies.get)
        >>>
        (Dict.get "expires" >> assertEqual (Nothing) >> test "test with expiry in past")
