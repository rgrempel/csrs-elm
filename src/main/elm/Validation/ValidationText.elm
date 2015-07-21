module Validation.ValidationText where

import Language.LanguageService exposing (Language(..))
import Validation.ValidationTypes exposing (..)
import Html exposing (Html, text)


translate : Language -> StringValidator -> Html 
translate language validator =
    text <| case validator of
        Required -> case language of
            EN -> "Required"
            FR -> "Requis"
            LA -> "Requiritur"

        Email -> case language of
            EN -> "Invalid"
            FR -> "Non valide"
            LA -> "Invalidum"

        GreaterThan a -> case language of
            EN -> "Must be greater than " ++ a
            FR -> "Must be greater than " ++ a
            LA -> "Must be greater than " ++ a

        Between a b -> case language of
            EN -> "Must be between " ++ a ++ " and " ++ b
            FR -> "Must be between " ++ a ++ " and " ++ b
            LA -> "Must be between " ++ a ++ " and " ++ b

        MinLength a -> case language of
            EN -> "Must be at least " ++ (toString a) ++ " characters"
            FR -> "Must be at least " ++ (toString a) ++ " characters"
            LA -> "Must be at least " ++ (toString a) ++ " characters"

        MaxLength a -> case language of
            EN -> "Must be no more than " ++ (toString a) ++ " characters"
            FR -> "Must be no more than " ++ (toString a) ++ " characters"
            LA -> "Must be no more than " ++ (toString a) ++ " characters"

        Matches a -> case language of
            EN -> "Does not match"
            FR -> "Does not match"
            LA -> "Does not match"

