module View.NavBar where

import Html exposing (Html, Attribute, nav, a, div, button, text, span, h1, p, ul, li)
import Html.Events exposing (onClick)
import Html.Attributes exposing (attribute, key, href, id, class, classList, type')

import Action exposing (Action, Action(SwitchLanguage, SwitchFocus))
import Model exposing (Model)
import Model.Focus as MF
import Version exposing (version)

import View.NavBar.Language as NL
import Model.Translation.Language as TL
import Model.Translation exposing (allLanguages)

import String
import Char

unbreakableSpace : String
unbreakableSpace = String.fromChar(Char.fromCode(160))

dataToggle : String -> Attribute
dataToggle action = attribute "data-toggle" action 

dataTarget : String -> Attribute
dataTarget action = attribute "data-target" action 

role : String -> Attribute
role theRole = attribute "role" theRole

glyphicon : String -> Html
glyphicon which = span [ class ("glyphicon glyphicon-" ++ which) ] []

dropdownToggle = 
    a
        [ class "dropdown-toggle"
        , dataToggle "dropdown"
        , href "#"
        ]

dropdownPointer : List Attribute -> List Html -> Html
dropdownPointer attrs =
    li <| [ class "dropdown pointer" ] ++ attrs

dropdownMenu = 
    ul [ class "dropdown-menu" ] 

view : Signal.Address Action -> Model -> Html
view address model =
    let 
        trans = NL.translate model.useLanguage

        navbarHeader = 
            div [ class "navbar-header" ]
                [ button 
                    [ class "navbar-toggle"
                    , type' "button"
                    , dataToggle "collapse"
                    , dataTarget "#navbar-collapse"
                    ]

                    (
                        ( span [ class "sr-only" ] [ trans NL.ToggleNavigation ] )
                        ::
                        ( List.repeat 3 (span [ class "icon-bar" ] []) )
                    )
                , span [class "navbar-brand"] 
                    [ trans NL.Title
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
                    [ homeButton
                    , accountMenu
                    , languageMenu
                    ]
                ]
        
        homeButton = 
            li [ classList [ ( "active", model.focus == MF.Home ) ] ]
                [ a [ onClick address ( SwitchFocus MF.Home ) ]
                    [ glyphicon "home"
                    , text unbreakableSpace
                    , trans NL.Home
                    ]
                ]

        languageMenu =
           dropdownPointer []
                [ dropdownToggle
                    [ glyphicon "flag"
                    , text unbreakableSpace
                    , span [ class "hidden-tablet" ] [ trans NL.Language ]
                    , text unbreakableSpace
                    , span [ class "text-bold caret" ] []
                    ]
                , dropdownMenu 
                    ( List.map languageItem allLanguages ) 
                ]

        languageItem lang =
            li 
                [ classList
                    [ ( "active", model.useLanguage == lang ) ]
                ]
                [ a
                    [ onClick address (SwitchLanguage lang) ]
                    [ TL.translate model.useLanguage (TL.Want lang) ]
                ]

        isAccountFocus =
            case model.focus of
                MF.Account _ -> True
                _ -> False

        accountMenu = 
            dropdownPointer [ classList [ ( "active", isAccountFocus ) ] ]  
                [ dropdownToggle
                    [ glyphicon "user"
                    , text unbreakableSpace
                    , span [ class "hidden-tablet" ] [ trans NL.Account ]
                    , text unbreakableSpace
                    , span [ class "text-bold caret" ] []
                    ]
                , dropdownMenu 
                    [ settingsItem
                    , passwordItem
                    , sessionsItem
                    , loginItem
                    , logoutItem
                    , registerItem
                    ]
                ]

        standardItem icon message focus =
            li [ classList [ ( "active", model.focus == focus ) ] ]
                [ a [ onClick address ( SwitchFocus focus ) ]
                    [ glyphicon icon
                    , text unbreakableSpace
                    , trans message
                    ]
                ]

        -- TODO: show/hide depending on whether logged in
        settingsItem =
            standardItem "wrench" NL.Settings ( MF.Account MF.Settings )
            
        passwordItem =
            standardItem "lock" NL.Password ( MF.Account MF.Password )

        sessionsItem =
            standardItem "cloud" NL.Sessions ( MF.Account MF.Sessions )

        logoutItem =
            standardItem "log-out" NL.Logout ( MF.Account MF.Logout )

        loginItem =
            standardItem "log-in" NL.Login ( MF.Account MF.Login )

        registerItem =
            standardItem "plus-sign" NL.Register ( MF.Account MF.Register )

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


