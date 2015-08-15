module Components.Account.AccountTypes where

import Components.Account.Login.LoginTypes as LoginTypes
import Components.Account.Logout.LogoutTypes as LogoutTypes
import Components.Account.Register.RegisterTypes as RegisterTypes
import Components.Account.ResetPassword.ResetPasswordTypes as ResetPasswordTypes
import Components.Account.Invitation.InvitationTypes as InvitationTypes
import Components.Account.Sessions.SessionsTypes as SessionsTypes
import Components.Account.ChangePassword.ChangePasswordTypes as ChangePasswordTypes


type Focus
    = Settings
    | Sessions SessionsTypes.Focus
    | Invitation InvitationTypes.Focus
    | Logout LogoutTypes.Focus
    | Login LoginTypes.Focus
    | Register RegisterTypes.Focus
    | ResetPassword ResetPasswordTypes.Focus
    | ChangePassword ChangePasswordTypes.Focus

type Action
    = FocusLogin LoginTypes.Action 
    | FocusSettings
    | FocusSessions SessionsTypes.Action
    | FocusInvitation InvitationTypes.Action
    | FocusLogout LogoutTypes.Action
    | FocusRegister RegisterTypes.Action
    | FocusResetPassword ResetPasswordTypes.Action
    | FocusChangePassword ChangePasswordTypes.Action


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


sessionsFocus : Focus -> Maybe SessionsTypes.Focus
sessionsFocus focus =
    case focus of
        Sessions subfocus -> Just subfocus
        _ -> Nothing


changePasswordFocus : Focus -> Maybe ChangePasswordTypes.Focus
changePasswordFocus focus =
    case focus of
        ChangePassword subfocus -> Just subfocus
        _ -> Nothing
