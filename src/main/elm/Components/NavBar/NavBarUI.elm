module Components.NavBar.NavBarUI where

import AppTypes exposing (..)
import Components.NavBar.NavBarText as NavBarText
import Html exposing (Html, Attribute, nav, a, div, button, text, span, h1, p, ul, li)
import Html.Attributes exposing (attribute, key, href, id, class, classList, type')
import Html.Util exposing (dataToggle, dataTarget, unbreakableSpace, role)
import Version exposing (version)


view : Model -> List Html -> Html
view model menus =
    let 
        trans =
            NavBarText.translate model.language.useLanguage 

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
                [ ul
                    [ class "nav navbar-nav nav-pills navbar-right" ]
                    menus
                ]
        
    in
        nav [ class "navbar navbar-default navbar-xs", role "navigation" ]
            [ div [ class "container" ]
                [ navbarHeader
                , navbarBody
                ]
            ]
  
