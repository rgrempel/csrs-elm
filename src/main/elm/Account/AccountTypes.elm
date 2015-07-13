module Account.AccountTypes where

import Account.Login.LoginTypes as LoginTypes
import Account.Logout.LogoutTypes as LogoutTypes

type Focus
    = Settings
    | Password
    | Sessions
    | Logout LogoutTypes.Focus
    | Login LoginTypes.Focus
    | Register

type Action
    = FocusLogin LoginTypes.Action 
    | FocusSettings
    | FocusPassword
    | FocusSessions
    | FocusLogout LogoutTypes.Action
    | FocusRegister


