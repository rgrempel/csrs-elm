module NavBar.NavBarUI where

import Html exposing (Html, Attribute, nav, a, div, button, text, span, h1, p, ul, li)
import Html.Events exposing (onClick)
import Html.Attributes exposing (attribute, key, href, id, class, classList, type')
import Html.Util exposing (dataToggle, dataTarget, unbreakableSpace, role)
import Language.LanguageService exposing (Language)
import Language.LanguageUI as LanguageUI
import Version exposing (version)
import NavBar.NavBarText as NavBarText
import Focus.FocusUI as FocusUI exposing (Focus)


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
                    (FocusUI.renderMenus focus language
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
        

{-

                li.dropdown.pointer(
                    ui-sref-active="active"
                    ng-switch-when="true"
                    ng-show="navbarController.isInRole('ROLE_ADMIN')"
                )
                    a.dropdown-toggle(
                        data-toggle="dropdown"
                        href=""
                    )
                        span
                            span.glyphicon.glyphicon-tower
                            | &#xA0;
                            span(
                                class="hidden-tablet"
                                translate="csrs.navbar.menu.tasks.main"
                            ) Tasks
                            | &#xA0;
                            span.text-bold.caret

                    ul.dropdown-menu
                        li(ui-sref-active="active")
                            a(ui-sref="processForms")
                                span.glyphicon.glyphicon-dashboard
                                | &#xA0;
                                span(translate="csrs.navbar.menu.tasks.processForms") Process Forms
                        
                        li(ui-sref-active="active")
                            a(ui-sref="contact-list")
                                span.glyphicon.glyphicon-dashboard
                                | &#xA0;
                                span(translate="csrs.navbar.menu.tasks.membershipByYear") Membership by Year
                                -}

