module Validation.ValidationText where

import Language.LanguageService exposing (Language(..))
import Validation.ValidationTypes exposing (..)
import Html exposing (Html, text)


translate : Language -> Validator a -> Html 
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

