module Account.AccountTypes where

import Account.Login.LoginTypes as LoginTypes
import Account.Logout.LogoutTypes as LogoutTypes
import Account.Register.RegisterTypes as RegisterTypes
import Account.ResetPassword.ResetPasswordTypes as ResetPasswordTypes
import Account.Invitation.InvitationTypes as InvitationTypes


type Focus
    = Settings
    | Password
    | Sessions
    | Invitation InvitationTypes.Focus
    | Logout LogoutTypes.Focus
    | Login LoginTypes.Focus
    | Register RegisterTypes.Focus
    | ResetPassword ResetPasswordTypes.Focus

type Action
    = FocusLogin LoginTypes.Action 
    | FocusSettings
    | FocusPassword
    | FocusSessions
    | FocusInvitation InvitationTypes.Action
    | FocusLogout LogoutTypes.Action
    | FocusRegister RegisterTypes.Action
    | FocusResetPassword ResetPasswordTypes.Action


loginFocus : Focus -> Maybe LoginTypes.Focus
loginFocus focus =
    case focus of
        Login subfocus -> Just subfocus
        _ -> Nothing
    

logoutFocus : Focus -> Maybe LogoutTypes.Focus
logoutFocus focus =
    case focus of
        Logout subfocus -> Just subfocus
        _ -> Nothing
    

resetPasswordFocus : Focus -> Maybe ResetPasswordTypes.Focus
resetPasswordFocus focus =
    case focus of
        ResetPassword subfocus -> Just subfocus
        _ -> Nothing
    

registerFocus : Focus -> Maybe RegisterTypes.Focus
registerFocus focus =
    case focus of
        Register subfocus -> Just subfocus
        _ -> Nothing
    

invitationFocus : Focus -> Maybe InvitationTypes.Focus
invitationFocus focus =
    case focus of
        Invitation subfocus -> Just subfocus
        _ -> Nothing
