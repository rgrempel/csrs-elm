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

                li.dropdown.pointer(
                    ng-class="{active: navbarController.stateIncludes('admin')}"
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
                            span.hidden-tablet(translate="csrs.navbar.menu.admin.main") Admin
                            | &#xA0;
                            span.text-bold.caret

                    ul.dropdown-menu
                        li(ui-sref-active="active")
                            a(ui-sref="metrics")
                                span.glyphicon.glyphicon-dashboard
                                | &#xA0;
                                span(translate="csrs.navbar.menu.admin.metrics") Metrics
                        
                        li(ui-sref-active="active")
                            a(ui-sref="health")
                                span.glyphicon.glyphicon-heart
                                | &#xA0;
                                span(translate="csrs.navbar.menu.admin.health") Health
                        
                        li(ui-sref-active="active")
                            a(ui-sref="configuration")
                                span.glyphicon.glyphicon-list-alt
                                | &#xA0;
                                span(translate="csrs.navbar.menu.admin.configuration") Configuration
                        
                        li(ui-sref-active="active")
                            a(ui-sref="audits")
                                span.glyphicon.glyphicon-bell
                                | &#xA0;
                                span(translate="csrs.navbar.menu.admin.audits") Audits
                        
                        li(ui-sref-active="active")
                            a(ui-sref="logs")
                                span.glyphicon.glyphicon-tasks
                                | &#xA0;
                                span(translate="csrs.navbar.menu.admin.logs") Logs
                        
                        li(ui-sref-active="active")
                            a(ui-sref="docs")
                                span.glyphicon.glyphicon-book
                                | &#xA0;
                                span(translate="csrs.navbar.menu.admin.apidocs") API Docs

                        li(ui-sref-active="active")
                            a(ui-sref="template-list")
                                span.glyphicon.glyphicon-blackboard
                                | &#xA0;
                                span(translate="csrs.navbar.menu.templates") Templates

                        li(ui-sref-active="active")
                            a(ui-sref="file-list")
                                span.glyphicon.glyphicon-picture
                                | &#xA0;
                                span(translate="csrs.navbar.menu.files") Images
-}


