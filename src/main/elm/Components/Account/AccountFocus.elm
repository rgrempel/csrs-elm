module Components.Account.AccountFocus where

import AppTypes exposing (..)
import RouteHash exposing (HashUpdate)

import Components.Account.AccountTypes exposing (..)
import Components.Account.Login.LoginFocus as LoginFocus
import Components.Account.Logout.LogoutFocus as LogoutFocus
import Components.Account.Register.RegisterFocus as RegisterFocus
import Components.Account.ResetPassword.ResetPasswordFocus as ResetPasswordFocus
import Components.Account.Invitation.InvitationFocus as InvitationFocus
import Components.Account.ChangePassword.ChangePasswordFocus as ChangePasswordFocus
import Components.Account.Sessions.SessionsFocus as SessionsFocus
import Components.Account.AccountText as AccountText

import Html exposing (Html, h1, text, div, li, ul, a, span)
import Html.Attributes exposing (class, classList, href, id)
import Signal exposing (Address, forwardTo)
import Html.Util exposing (dropdownMenu, dropdownToggle, dropdownPointer, glyphicon, unbreakableSpace)
import Task exposing (Task)


subcomponent : SubComponent Action Focus
subcomponent =
    { route = route
    , path = path
    , reaction = Just reaction
    , update = update
    , view = view
    , menu = Just menu
    }


login =
    superComponent <|
        MakeComponent "login" FocusLogin Login loginFocus LoginFocus.subcomponent

logout =
    superComponent <|
        MakeComponent "logout" FocusLogout Logout logoutFocus LogoutFocus.subcomponent

register =
    superComponent <|
        MakeComponent "register" FocusRegister Register registerFocus RegisterFocus.subcomponent

resetPassword =
    superComponent <|
        MakeComponent "reset-password" FocusResetPassword ResetPassword resetPasswordFocus ResetPasswordFocus.subcomponent

invitation =
    superComponent <|
        MakeComponent "invitation" FocusInvitation Invitation invitationFocus InvitationFocus.subcomponent

changePassword =
    superComponent <|
        MakeComponent "change-password" FocusChangePassword ChangePassword changePasswordFocus ChangePasswordFocus.subcomponent

sessions =
    superComponent <|
        MakeComponent "sessions" FocusSessions Sessions sessionsFocus SessionsFocus.subcomponent


route : List String -> Maybe Action
route list =
    Maybe.oneOf
        [ login.route list
        , logout.route list
        , register.route list
        , resetPassword.route list
        , invitation.route list
        , changePassword.route list
        , sessions.route list
        ]


path : Maybe Focus -> Focus -> Maybe HashUpdate
path focus focus' =
    case focus' of
        Login subfocus ->
            login.path focus subfocus

        Logout subfocus ->
            logout.path focus subfocus

        Register subfocus ->
            register.path focus subfocus

        ResetPassword subfocus ->
            resetPassword.path focus subfocus

        Invitation subfocus ->
            invitation.path focus subfocus

        ChangePassword subfocus ->
            changePassword.path focus subfocus

        Sessions subfocus ->
            sessions.path focus subfocus

        _ ->
            Nothing


reaction : Address Action -> Action -> Maybe Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        FocusLogin subaction ->
            login.reaction address subaction focus

        FocusLogout subaction ->
            logout.reaction address subaction focus
        
        FocusRegister subaction ->
            register.reaction address subaction focus
        
        FocusResetPassword subaction ->
            resetPassword.reaction address subaction focus
        
        FocusInvitation subaction ->
            invitation.reaction address subaction focus
        
        FocusSessions subaction ->
            sessions.reaction address subaction focus
        
        FocusChangePassword subaction ->
            changePassword.reaction address subaction focus
        
        _ ->
            Nothing


update : Action -> Maybe Focus -> Maybe Focus
update action focus =
    case action of
        FocusLogin subaction ->
            login.update subaction focus

        FocusLogout subaction  ->
            logout.update subaction focus

        FocusRegister subaction ->
            register.update subaction focus

        FocusResetPassword subaction ->
            resetPassword.update subaction focus

        FocusInvitation subaction  ->
            invitation.update subaction focus

        FocusChangePassword subaction  ->
            changePassword.update subaction focus

        FocusSessions subaction  ->
            sessions.update subaction focus

        _ ->
            Nothing


view : Address Action -> Model -> Focus -> Html
view address model focus =
    case focus of
        Sessions subfocus ->
            sessions.view address model subfocus
        
        ResetPassword subfocus ->
            resetPassword.view address model subfocus
        
        ChangePassword subfocus ->
            changePassword.view address model subfocus
        
        Invitation subfocus ->
            invitation.view address model subfocus
        
        Register subfocus ->
            register.view address model subfocus
        
        Logout subfocus ->
            logout.view address model subfocus
        
        Login subfocus ->
            login.view address model subfocus
 

menu : Address Action -> Model -> Maybe Focus -> Maybe Html
menu address model focus =
    let
        trans =
            AccountText.translate model.language.useLanguage

        user =
            model.account.currentUser

    in
        Just <|
            dropdownPointer [ classList [ ( "active", focus /= Nothing ) ] ]
                [ dropdownToggle [ id "navbar-account-menu" ]
                    [ glyphicon "user"
                    , text unbreakableSpace
                    , span [ class "hidden-tablet" ] [ trans AccountText.Title ]
                    , text unbreakableSpace
                    , span [ class "text-bold caret" ] []
                    ]
                , dropdownMenu <|
                    List.filterMap identity
                        -- Note that each of these manages for itself whether
                        -- to be shown depending on whether a user is logged in.
                        [ login.menu address model focus
                        , register.menu address model focus
                        , logout.menu address model focus
                        , changePassword.menu address model focus
                        , sessions.menu address model focus
                        ]
                ]

