module Focus.FocusUITest where

import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)

import Focus.FocusUI exposing (removeInitial, removeAnyInitial)

tests : Test
tests =
    suite "Focus"
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
                assertEqual "baseball" <| removeAnyInitial "con" "baseball"
            , test "when whole present" <|
                assertEqual "ball" <| removeAnyInitial "base" "baseball"
            , test "when first part present" <|
                assertEqual "seball" <| removeAnyInitial "bark" "baseball"
            , test "when last part present" <|
                assertEqual "seball" <| removeAnyInitial "krba" "baseball"
            , test "when last part present but order wrong" <|
                assertEqual "aseball" <| removeAnyInitial "krab" "baseball"
            , test "when parts interspersed" <|
                assertEqual "seball" <| removeAnyInitial "abcdaeb" "baseball"
            ]
        ]

