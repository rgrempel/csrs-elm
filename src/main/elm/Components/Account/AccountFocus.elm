module Components.Account.AccountFocus where

import AppTypes exposing (..)
import Route.RouteService as RouteService exposing (PathAction(..))

import Components.Account.AccountTypes exposing (..)
import Components.Account.Login.LoginFocus as LoginFocus
import Components.Account.Logout.LogoutFocus as LogoutFocus
import Components.Account.Register.RegisterFocus as RegisterFocus
import Components.Account.ResetPassword.ResetPasswordFocus as ResetPasswordFocus
import Components.Account.Invitation.InvitationFocus as InvitationFocus
import Components.Account.ChangePassword.ChangePasswordFocus as ChangePasswordFocus
import Components.Account.AccountText as AccountText

import Html exposing (Html, h1, text, div, li, ul, a, span)
import Html.Attributes exposing (class, classList, href, id)
import Html.Events exposing (onClick)
import Signal exposing (Address, forwardTo)
import Html.Util exposing (dropdownMenu, dropdownToggle, dropdownPointer, glyphicon, unbreakableSpace)
import Task exposing (Task)


route : List String -> Maybe Action
route hashList =
    case hashList of
        first :: rest ->
            case first of
                "login" ->
                    Maybe.map FocusLogin <| LoginFocus.route rest

                "logout" ->
                    Maybe.map FocusLogout <| LogoutFocus.route rest

                "register" ->
                    Maybe.map FocusRegister <| RegisterFocus.route rest

                "reset-password" ->
                    Maybe.map FocusResetPassword <| ResetPasswordFocus.route rest
               
                "invitation" ->
                    Maybe.map FocusInvitation <| InvitationFocus.route rest

                "settings" ->
                    Just FocusSettings

                "change-password" ->
                    Maybe.map FocusChangePassword <| ChangePasswordFocus.route rest

                "sessions" ->
                    Just FocusSessions

                _ ->
                    Nothing

        _ ->
            Nothing


path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' =
    let
        prepend prefix =
            Maybe.map (RouteService.map ((::) prefix))
    
    in
        case focus' of
            Login subfocus ->
                prepend "login" (LoginFocus.path (focus `Maybe.andThen` loginFocus) subfocus)

            Logout subfocus ->
                prepend "logout" (LogoutFocus.path (focus `Maybe.andThen` logoutFocus) subfocus)

            Register subfocus ->
                prepend "register" (RegisterFocus.path (focus `Maybe.andThen` registerFocus) subfocus)

            ResetPassword subfocus ->
                prepend "reset-password" (ResetPasswordFocus.path (focus `Maybe.andThen` resetPasswordFocus) subfocus)

            Invitation subfocus ->
                prepend "invitation" (InvitationFocus.path (focus `Maybe.andThen` invitationFocus) subfocus)

            Settings ->
                if focus == Just Settings
                    then Nothing 
                    else Just <| SetPath ["settings"]
            
            ChangePassword subfocus ->
                prepend "change-password" (ChangePasswordFocus.path (focus `Maybe.andThen` changePasswordFocus) subfocus)

            Sessions ->
                if focus == Just Sessions
                    then Nothing
                    else Just <| SetPath ["sessions"]


reaction : Address Action -> Action -> Maybe Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        FocusLogin subaction ->
            LoginFocus.reaction (forwardTo address FocusLogin) subaction <| focus `Maybe.andThen` loginFocus

        FocusLogout subaction ->
            LogoutFocus.reaction (forwardTo address FocusLogout) subaction <| focus `Maybe.andThen` logoutFocus
        
        FocusRegister subaction ->
            RegisterFocus.reaction (forwardTo address FocusRegister) subaction <| focus `Maybe.andThen` registerFocus
        
        FocusResetPassword subaction ->
            ResetPasswordFocus.reaction (forwardTo address FocusResetPassword) subaction <| focus `Maybe.andThen` resetPasswordFocus
        
        FocusInvitation subaction ->
            InvitationFocus.reaction (forwardTo address FocusInvitation) subaction <| focus `Maybe.andThen` invitationFocus
        
        FocusChangePassword subaction ->
            ChangePasswordFocus.reaction (forwardTo address FocusChangePassword) subaction <| focus `Maybe.andThen` changePasswordFocus
        
        _ ->
            Nothing


update : Action -> Maybe Focus -> Maybe Focus
update action focus =
    case action of
        FocusLogin subaction ->
            Maybe.map Login <| LoginFocus.update subaction <| focus `Maybe.andThen` loginFocus

        FocusLogout subaction  ->
            Maybe.map Logout <| LogoutFocus.update subaction <| focus `Maybe.andThen` logoutFocus

        FocusRegister subaction ->
            Maybe.map Register <| RegisterFocus.update subaction <| focus `Maybe.andThen` registerFocus

        FocusResetPassword subaction ->
            Maybe.map ResetPassword <| ResetPasswordFocus.update subaction <| focus `Maybe.andThen` resetPasswordFocus

        FocusInvitation subaction  ->
            Maybe.map Invitation <| InvitationFocus.update subaction <| focus `Maybe.andThen` invitationFocus

        FocusSettings ->
            Just Settings

        FocusChangePassword subaction  ->
            Maybe.map ChangePassword <| ChangePasswordFocus.update subaction <| focus `Maybe.andThen` changePasswordFocus

        FocusSessions ->
            Just Sessions

        _ ->
            Nothing


view : Address Action -> Model -> Focus -> Html
view address model focus =
    let 
        v s =
            div [ class "container" ]
                [ h1 [] [ text s ]
                ]

        forward =
            forwardTo address

    in
        case focus of
            Settings -> v "Settings"
            Sessions -> v "Sessions"
            
            ResetPassword subfocus ->
                ResetPasswordFocus.view (forward FocusResetPassword) model subfocus
            
            ChangePassword subfocus ->
                ChangePasswordFocus.view (forward FocusChangePassword) model subfocus
            
            Invitation subfocus ->
                InvitationFocus.view (forward FocusInvitation) model subfocus
            
            Register subfocus ->
                RegisterFocus.view (forward FocusRegister) model subfocus
            
            Logout subfocus ->
                LogoutFocus.view (forward FocusLogout) model subfocus
            
            Login subfocus ->
                LoginFocus.view (forward FocusLogin) model subfocus
 

menu : Address Action -> Model -> Maybe Focus -> Html
menu address model focus =
    let
        trans =
            AccountText.translate model.useLanguage

        user =
            model.currentUser

        standardMenuItem icon message action newFocus =
            li [ classList [ ( "active", focus == Just newFocus ) ] ]
                [ a [ onClick address action ]
                    [ glyphicon icon
                    , text unbreakableSpace
                    , trans message
                    ]
                ]

        forward =
            forwardTo address
 
    in
        dropdownPointer [ classList [ ( "active", focus /= Nothing ) ] ]
            [ dropdownToggle [ id "navbar-account-menu" ]
                [ glyphicon "user"
                , text unbreakableSpace
                , span [ class "hidden-tablet" ] [ trans AccountText.Title ]
                , text unbreakableSpace
                , span [ class "text-bold caret" ] []
                ]
            , dropdownMenu <|
                if user == Nothing then
                    [ LoginFocus.menuItem (forward FocusLogin) model (focus `Maybe.andThen` loginFocus)
                    , RegisterFocus.menuItem (forward FocusRegister) model (focus `Maybe.andThen` registerFocus)
                    ]
                else
                    [ LogoutFocus.menuItem (forward FocusLogout) model (focus `Maybe.andThen` logoutFocus)
                    , ChangePasswordFocus.menuItem (forward FocusChangePassword) model (focus `Maybe.andThen` changePasswordFocus)
                    , standardMenuItem "cloud" AccountText.Sessions FocusSessions Sessions
                    , standardMenuItem "wrench" AccountText.Settings FocusSettings Settings
                    ]
            ]

