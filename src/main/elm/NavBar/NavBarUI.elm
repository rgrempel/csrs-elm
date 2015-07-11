module NavBar.NavBarUI where

import Html exposing (Html, Attribute, nav, a, div, button, text, span, h1, p, ul, li)
import Html.Attributes exposing (attribute, key, href, id, class, classList, type')
import Html.Util exposing (dataToggle, dataTarget, unbreakableSpace, role)
import Language.LanguageService exposing (Language)
import Language.LanguageUI as LanguageUI
import Version exposing (version)
import NavBar.NavBarText as NavBarText
import Focus.FocusTypes exposing (Focus)
import Focus.FocusUI exposing (renderMenus)


render : Focus -> Language -> Html
render focus language =
    let 
        trans = NavBarText.translate language 

        navbarHeader = 
            div [ class "navbar-header" ]
                [ button 
                    [ class "navbar-toggle"
                    , type' "button"
                    , dataToggle "collapse"
                    , dataTarget "#navbar-collapse"
                    ]

                    (
                        ( span [ class "sr-only" ] [ trans NavBarText.ToggleNavigation ] )
                        ::
                        ( List.repeat 3 (span [ class "icon-bar" ] []) )
                    )
                , span [class "navbar-brand"] 
                    [ trans NavBarText.Title
                    , text unbreakableSpace
                    , span [class "navbar-version"]
                        [ text ("v" ++ version) ]
                    ]
                ]
        
        navbarBody =
            div
                [ class "collapse navbar-collapse"
                , id "navbar-collapse"
                ]
                [ ul [ class "nav navbar-nav nav-pills navbar-right" ]
                    (renderMenus focus language
                    ++
                    [ LanguageUI.renderMenu language
                    ])
                ]
        
    in
        nav [ class "navbar navbar-default navbar-xs", role "navigation" ]
            [ div [ class "container" ]
                [ navbarHeader
                , navbarBody
                ]
            ]
  
