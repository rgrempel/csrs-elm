module Language.LanguageText where

import Language.LanguageService exposing (Language(EN, FR, LA))
import Html exposing (Html, text)

type Message
    = TheWordFor Language
    | TheWordLanguage

translate : Language -> Message -> Html
translate language message =
    text <|
        case message of
            TheWordLanguage ->
                case language of
                    EN -> "Language"
                    FR -> "Langue"
                    LA -> "Lingua"

            TheWordFor target ->
                case target of
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

