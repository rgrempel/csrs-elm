module Account.AccountFocus where

import Account.AccountTypes exposing (..)
import Html exposing (Html, h1, text, div, li, ul, a, span)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)
import Signal exposing (Address, forwardTo)
import Account.Login.LoginFocus as LoginFocus
import Account.Login.LoginTypes as LoginTypes
import Account.Logout.LogoutFocus as LogoutFocus
import Account.Logout.LogoutTypes as LogoutTypes
import Account.AccountText as AccountText
import Language.LanguageService exposing (Language)
import Html.Util exposing (dropdownMenu, dropdownToggle, dropdownPointer, glyphicon, unbreakableSpace)
import Task exposing (Task)


hash2focus : List String -> Maybe Focus
hash2focus hashList =
    case hashList of
        first :: rest ->
            case first of
                "login" ->
                    Maybe.map Login <| LoginFocus.hash2focus rest

                "logout" ->
                    Maybe.map Logout <| LogoutFocus.hash2focus rest

                "settings" ->
                    Just Settings

                "password" ->
                    Just Password

                "sessions" ->
                    Just Sessions

                "register" ->
                    Just Register

                _ ->
                    Nothing

        _ ->
            Nothing


focus2hash : Focus -> List String
focus2hash focus =
    case focus of
        Login loginFocus ->
            "login" :: LoginFocus.focus2hash loginFocus

        Logout logoutFocus ->
            "logout" :: LogoutFocus.focus2hash logoutFocus

        Settings ->
            ["settings"]

        Password ->
            ["password"]

        Sessions ->
            ["sessions"]

        Register ->
            ["register"]


reaction : Address Action -> Action -> Maybe (Task () ())
reaction address action =
    case action of
        FocusLogin action ->
            LoginFocus.reaction (forwardTo address FocusLogin) action

        FocusLogout action ->
            LogoutFocus.reaction (forwardTo address FocusLogout) action
        
        _ ->
            Nothing


updateFocus : Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    case (action, focus) of
        (FocusLogin loginAction, Just (Login loginFocus)) ->
            Maybe.map Login <| LoginFocus.updateFocus loginAction <| Just loginFocus

        (FocusLogin loginAction, _) ->
            Maybe.map Login <| LoginFocus.updateFocus loginAction Nothing
        
        (FocusLogout logoutAction, Just (Logout logoutFocus)) ->
            Maybe.map Logout <| LogoutFocus.updateFocus logoutAction <| Just logoutFocus

        (FocusLogout logoutAction, _) ->
            Maybe.map Logout <| LogoutFocus.updateFocus logoutAction Nothing
        
        (FocusSettings, _) ->
            Just Settings

        (FocusPassword, _) ->
            Just Password

        (FocusSessions, _) ->
            Just Sessions

        (FocusRegister, _) ->
            Just Register

        _ ->
            Nothing


renderFocus : Address Action -> Focus -> Language -> Html
renderFocus address focus language =
    let 
        v s =
            div [ class "container" ]
                [ h1 [] [ text s ]
                ]

    in
        case focus of
            Settings -> v "Settings"
            Password -> v "Password"
            Sessions -> v "Sessions"
            Register -> v "Register"
            
            Logout logoutFocus ->
                LogoutFocus.renderFocus
                    (forwardTo address FocusLogout)
                    logoutFocus
                    language
            
            Login loginFocus ->
                LoginFocus.renderFocus
                    (forwardTo address FocusLogin)
                    loginFocus
                    language


loginFocus : Maybe Focus -> Maybe LoginTypes.Focus
loginFocus focus =
    case focus of
        Just (Login loginFocus) -> Just loginFocus
        _ -> Nothing
    

logoutFocus : Maybe Focus -> Maybe LogoutTypes.Focus
logoutFocus focus =
    case focus of
        Just (Logout logoutFocus) -> Just logoutFocus
        _ -> Nothing
    

renderMenu : Address Action -> Maybe Focus -> Language -> Html
renderMenu address focus language =
    let
        trans =
            AccountText.translate language

        standardMenuItem icon message action newFocus =
            li [ classList [ ( "active", focus == Just newFocus ) ] ]
                [ a [ onClick address action ]
                    [ glyphicon icon
                    , text unbreakableSpace
                    , trans message
                    ]
                ]

        -- TODO: show/hide depending on whether logged in
        settingsItem =
            standardMenuItem "wrench" AccountText.Settings FocusSettings Settings
            
        passwordItem =
            standardMenuItem "lock" AccountText.Password FocusPassword Password

        sessionsItem =
            standardMenuItem "cloud" AccountText.Sessions FocusSessions Sessions

        registerItem =
            standardMenuItem "plus-sign" AccountText.Register FocusRegister Register
    
    in
        dropdownPointer [ classList [ ( "active", focus /= Nothing ) ] ]
            [ dropdownToggle
                [ glyphicon "user"
                , text unbreakableSpace
                , span [ class "hidden-tablet" ] [ trans AccountText.Title ]
                , text unbreakableSpace
                , span [ class "text-bold caret" ] []
                ]
            , dropdownMenu 
                [ settingsItem
                , passwordItem
                , sessionsItem

                , LoginFocus.renderMenuItem
                    (forwardTo address FocusLogin)
                    (loginFocus focus)
                    language

                , LogoutFocus.renderMenuItem
                    (forwardTo address FocusLogout)
                    (logoutFocus focus)
                    language

                , registerItem
                ]
            ]


