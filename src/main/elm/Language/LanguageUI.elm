module Language.LanguageUI where

import AppTypes exposing (..)
import Language.LanguageTypes exposing (..)
import Language.LanguageText as LanguageText
import Html.Util exposing (dropdownPointer, dropdownToggle, glyphicon, unbreakableSpace, dropdownMenu)
import Html exposing (Html, li, a, text, span)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)


menu : Model -> Html
menu model =
    let
        trans =
            LanguageText.translate model.language.useLanguage

        languageItem lang =
            li
                [ classList
                    [ ( "active", model.language.useLanguage == lang ) ]
                ]
                [ a
                    [ onClick actions.address <| SwitchLanguage lang ]
                    [ trans <| LanguageText.TheWordFor lang ]
                ]

    in
        dropdownPointer []
            [ dropdownToggle []
                [ glyphicon "flag"
                , text unbreakableSpace
                , span [ class "hidden-tablet" ] [ trans LanguageText.TheWordLanguage ]
                , text unbreakableSpace
                , span [ class "text-bold caret" ] []
                ]
            , dropdownMenu <| List.map languageItem allLanguages
            ]
