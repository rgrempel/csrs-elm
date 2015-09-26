module Route.RouteTest where

import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)

import Route.RouteService exposing (removeInitial, removeInitialSequence)

tests : Test
tests =
    suite "RouteService"
        [ suite "removeInitial"
            [ test "when present" <|
                assertEqual "ob"  <| removeInitial 'b' "bob"
            , test "when absent" <|
                assertEqual "cob" <| removeInitial 'b' "cob"
            , test "empty original" <|
                assertEqual "" <| removeInitial 'b' ""
            ]
        , suite "removeAnyInitial"
            [ test "when absent" <|
                assertEqual "baseball" <| removeInitialSequence "con" "baseball"
            , test "when whole present" <|
                assertEqual "ball" <| removeInitialSequence "base" "baseball"
            , test "when first part present" <|
                assertEqual "seball" <| removeInitialSequence "bark" "baseball"
            , test "when last part present" <|
                assertEqual "seball" <| removeInitialSequence "krba" "baseball"
            , test "when last part present but order wrong" <|
                assertEqual "aseball" <| removeInitialSequence "krab" "baseball"
            , test "when parts interspersed" <|
                assertEqual "seball" <| removeInitialSequence "abcdaeb" "baseball"
            ]
        ]

