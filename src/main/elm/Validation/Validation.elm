module Validation.Validation where

import String exposing (trim)
import List exposing (filter)
import Html exposing (Html, p, text)
import Html.Attributes exposing (class)
import Validation.ValidationText exposing (translate)
import Validation.ValidationTypes exposing (..)
import Language.LanguageService exposing (Language)
import Regex exposing (regex, caseInsensitive, contains)


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


    in
        filter (not << check) validators


helpBlock : Language -> Validator a -> Html
helpBlock language validator =
    p
        [ class "help-block" ] 
        [ translate language validator ]
