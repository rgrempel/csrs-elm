module Validation.Validation where

import String exposing (trim)
import List exposing (filter)
import Html exposing (Html, p, text)
import Html.Attributes exposing (class)
import Validation.ValidationText exposing (translate)
import Validation.ValidationTypes exposing (..)
import Language.LanguageTypes exposing (Language)
import Regex exposing (regex, caseInsensitive, contains)
import Dict exposing (Dict)
import Maybe exposing (withDefault)


validEmail : String -> Bool
validEmail =
    contains <| caseInsensitive <|
        -- based on regex used in Angular.js
        regex "^[a-z0-9!#$%&'*+/=?^_`{|}~.-]+@[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$"


-- Given a list of validators, returns the list which fail
checkString : List StringValidator -> String -> List StringValidator
checkString validators value =
    let
        -- true if value is good, false if value is bad
        check validator =
            case validator of
                Required ->
                    String.trim(value) /= ""

                GreaterThan other ->
                    value > other

                Between low high ->
                    value > low && value < high

                Email ->
                    value == "" || validEmail value

                MinLength min ->
                    String.length (String.trim value) >= min

                MaxLength max ->
                    String.length (String.trim value) <= max

                Matches other ->
                    value == other

                NotTaken dict ->
                    not <| withDefault False (Dict.get value dict) 

    in
        filter (not << check) validators


helpBlock : Language -> StringValidator -> Html
helpBlock language validator =
    p
        [ class "help-block" ] 
        [ translate language validator ]
