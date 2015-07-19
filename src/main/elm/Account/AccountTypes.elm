module Account.AccountTypes where

import Account.Login.LoginTypes as LoginTypes
import Account.Logout.LogoutTypes as LogoutTypes
import Account.Register.RegisterTypes as RegisterTypes
import Account.ResetPassword.ResetPasswordTypes as ResetPasswordTypes

type Focus
    = Settings
    | Password
    | Sessions
    | Logout LogoutTypes.Focus
    | Login LoginTypes.Focus
    | Register RegisterTypes.Focus
    | ResetPassword ResetPasswordTypes.Focus

type Action
    = FocusLogin LoginTypes.Action 
    | FocusSettings
    | FocusPassword
    | FocusSessions
    | FocusLogout LogoutTypes.Action
    | FocusRegister RegisterTypes.Action
    | FocusResetPassword ResetPasswordTypes.Action


