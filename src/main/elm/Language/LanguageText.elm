module Language.LanguageText where

import Language.LanguageService exposing (Language(EN, FR, LA))
import Html exposing (Html, text)

type alias Message = Language

translate : Language -> Message -> Html
translate language message =
    text <|
        case message of
            EN -> case language of
                EN -> "English"
                FR -> "Anglais"
                LA -> "Anglicus"

            FR -> case language of
                EN -> "French"
                FR -> "Français"
                LA -> "Gallicus"

            LA -> case language of
                EN -> "Latin"
                FR -> "Latin"
                LA -> "Latina"

