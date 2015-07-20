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
import Account.Register.RegisterFocus as RegisterFocus
import Account.Register.RegisterTypes as RegisterTypes
import Account.ResetPassword.ResetPasswordFocus as ResetPasswordFocus
import Account.ResetPassword.ResetPasswordTypes as ResetPasswordTypes
import Account.Invitation.InvitationFocus as InvitationFocus
import Account.Invitation.InvitationTypes as InvitationTypes
import Account.AccountText as AccountText
import Account.AccountService exposing (User)
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

                "register" ->
                    Maybe.map Register <| RegisterFocus.hash2focus rest

                "reset-password" ->
                    Maybe.map ResetPassword <| ResetPasswordFocus.hash2focus rest
               
                "invitation" ->
                    Maybe.map Invitation <| InvitationFocus.hash2focus rest

                "settings" ->
                    Just Settings

                "password" ->
                    Just Password

                "sessions" ->
                    Just Sessions

                _ ->
                    Nothing

        _ ->
            Nothing


focus2hash : Focus -> List String
focus2hash focus =
    case focus of
        Login focus ->
            "login" :: LoginFocus.focus2hash focus

        Logout focus ->
            "logout" :: LogoutFocus.focus2hash focus

        Register focus ->
            "register" :: RegisterFocus.focus2hash focus

        ResetPassword focus ->
            "reset-password" :: ResetPasswordFocus.focus2hash focus

        Invitation focus ->
            "invitation" :: InvitationFocus.focus2hash focus

        Settings ->
            ["settings"]

        Password ->
            ["password"]

        Sessions ->
            ["sessions"]


reaction : Address Action -> Action -> Maybe (Task () ())
reaction address action =
    case action of
        FocusLogin action ->
            LoginFocus.reaction (forwardTo address FocusLogin) action

        FocusLogout action ->
            LogoutFocus.reaction (forwardTo address FocusLogout) action
        
        FocusRegister action ->
            RegisterFocus.reaction (forwardTo address FocusRegister) action
        
        FocusResetPassword action ->
            ResetPasswordFocus.reaction (forwardTo address FocusResetPassword) action
        
        FocusInvitation action ->
            InvitationFocus.reaction (forwardTo address FocusInvitation) action
        
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
        
        (FocusRegister registerAction, Just (Register registerFocus)) ->
            Maybe.map Register <| RegisterFocus.updateFocus registerAction <| Just registerFocus

        (FocusRegister registerAction, _) ->
            Maybe.map Register <| RegisterFocus.updateFocus registerAction Nothing
        
        (FocusResetPassword resetPasswordAction, Just (ResetPassword resetPasswordFocus)) ->
            Maybe.map ResetPassword <| ResetPasswordFocus.updateFocus resetPasswordAction <| Just resetPasswordFocus

        (FocusResetPassword resetPasswordAction, _) ->
            Maybe.map ResetPassword <| ResetPasswordFocus.updateFocus resetPasswordAction Nothing
        
        (FocusInvitation action, Just (Invitation focus)) ->
            Maybe.map Invitation <| InvitationFocus.updateFocus action <| Just focus

        (FocusInvitation action, _) ->
            Maybe.map Invitation <| InvitationFocus.updateFocus action Nothing
        
        (FocusSettings, _) ->
            Just Settings

        (FocusPassword, _) ->
            Just Password

        (FocusSessions, _) ->
            Just Sessions

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
            
            ResetPassword focus ->
                ResetPasswordFocus.renderFocus
                    (forwardTo address FocusResetPassword)
                    focus
                    language
            
            Invitation focus ->
                InvitationFocus.renderFocus
                    (forwardTo address FocusInvitation)
                    focus
                    language
            
            Register registerFocus ->
                RegisterFocus.renderFocus
                    (forwardTo address FocusRegister)
                    registerFocus
                    language
            
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
    

resetPasswordFocus : Maybe Focus -> Maybe ResetPasswordTypes.Focus
resetPasswordFocus focus =
    case focus of
        Just (ResetPassword resetPasswordFocus) -> Just resetPasswordFocus
        _ -> Nothing
    

registerFocus : Maybe Focus -> Maybe RegisterTypes.Focus
registerFocus focus =
    case focus of
        Just (Register registerFocus) -> Just registerFocus
        _ -> Nothing
    

invitationFocus : Maybe Focus -> Maybe InvitationTypes.Focus
invitationFocus focus =
    case focus of
        Just (Invitation focus) -> Just focus
        _ -> Nothing
    

renderMenu : Address Action -> Maybe User -> Maybe Focus -> Language -> Html
renderMenu address user focus language =
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

        loginItem = 
            LoginFocus.renderMenuItem
                (forwardTo address FocusLogin)
                (loginFocus focus)
                language

        logoutItem =
            LogoutFocus.renderMenuItem
                (forwardTo address FocusLogout)
                (logoutFocus focus)
                language

        registerItem =
            RegisterFocus.renderMenuItem
                (forwardTo address FocusRegister)
                (registerFocus focus)
                language
    
    in
        dropdownPointer [ classList [ ( "active", focus /= Nothing ) ] ]
            [ dropdownToggle
                [ glyphicon "user"
                , text unbreakableSpace
                , span [ class "hidden-tablet" ] [ trans AccountText.Title ]
                , text unbreakableSpace
                , span [ class "text-bold caret" ] []
                ]
            , dropdownMenu <|
                if user == Nothing then
                    [ loginItem
                    , registerItem
                    ]
                else
                    [ logoutItem
                    , sessionsItem
                    , passwordItem
                    , settingsItem
                    ]
            ]

