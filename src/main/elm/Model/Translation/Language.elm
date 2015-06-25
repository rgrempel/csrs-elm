module Model.Translation.Language where

import Model.Translation exposing (Language(EN, FR, LA))
import Html exposing (Html, text)

type Message
    = Want Language

translate : Language -> Message -> Html
translate language message =
    text <|
        case message of
            Want EN -> case language of
                EN -> "English"
                FR -> "Anglais"
                LA -> "Anglicus"

            Want FR -> case language of
                EN -> "French"
                FR -> "Français"
                LA -> "Gallicus"

            Want LA -> case language of
                EN -> "Latin"
                FR -> "Latin"
                LA -> "Latina"

