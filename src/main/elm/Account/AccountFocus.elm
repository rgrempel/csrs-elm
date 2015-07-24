module Account.AccountFocus where

import AppTypes exposing (..)
import Account.AccountTypes exposing (..)
import Account.Login.LoginFocus as LoginFocus
import Account.Logout.LogoutFocus as LogoutFocus
import Account.Register.RegisterFocus as RegisterFocus
import Account.ResetPassword.ResetPasswordFocus as ResetPasswordFocus
import Account.Invitation.InvitationFocus as InvitationFocus
import Account.AccountText as AccountText
import Route.RouteService as RouteService exposing (PathAction(..))

import Html exposing (Html, h1, text, div, li, ul, a, span)
import Html.Attributes exposing (class, classList, href)
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

                "password" ->
                    Just FocusPassword

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
            
            Password ->
                if focus == Just Password
                    then Nothing
                    else Just <| SetPath ["password"]

            Sessions ->
                if focus == Just Sessions
                    then Nothing
                    else Just <| SetPath ["sessions"]


reaction : Address Action -> Action -> Maybe (Task () ())
reaction address action =
    case action of
        FocusLogin subaction ->
            LoginFocus.reaction (forwardTo address FocusLogin) subaction

        FocusLogout subaction ->
            LogoutFocus.reaction (forwardTo address FocusLogout) subaction
        
        FocusRegister subaction ->
            RegisterFocus.reaction (forwardTo address FocusRegister) subaction
        
        FocusResetPassword subaction ->
            ResetPasswordFocus.reaction (forwardTo address FocusResetPassword) subaction
        
        FocusInvitation subaction ->
            InvitationFocus.reaction (forwardTo address FocusInvitation) subaction
        
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

        FocusPassword ->
            Just Password

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
            Password -> v "Password"
            Sessions -> v "Sessions"
            
            ResetPassword subfocus ->
                ResetPasswordFocus.view (forward FocusResetPassword) model subfocus
            
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
            [ dropdownToggle
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
                    , standardMenuItem "cloud" AccountText.Sessions FocusSessions Sessions
                    , standardMenuItem "lock" AccountText.Password FocusPassword Password
                    , standardMenuItem "wrench" AccountText.Settings FocusSettings Settings
                    ]
            ]

