module Language.LanguageUI where

import Language.LanguageService exposing (Language, allLanguages, service, Action(SwitchLanguage))
import Language.LanguageText as LanguageText
import Html.Util exposing (dropdownPointer, dropdownToggle, glyphicon, unbreakableSpace, dropdownMenu)
import Html exposing (Html, li, a, text, span)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)


renderMenu : Language -> Html
renderMenu language =
    let
        trans =
            LanguageText.translate language

        languageItem lang =
            li
                [ classList
                    [ ( "active", language == lang ) ]
                ]
                [ a
                    [ onClick (.address service) (SwitchLanguage lang) ]
                    [ trans <| LanguageText.TheWordFor lang ]
                ]

    in
        dropdownPointer []
            [ dropdownToggle
                [ glyphicon "flag"
                , text unbreakableSpace
                , span [ class "hidden-tablet" ] [ trans LanguageText.TheWordLanguage ]
                , text unbreakableSpace
                , span [ class "text-bold caret" ] []
                ]
            , dropdownMenu
                ( List.map languageItem allLanguages )
            ]
