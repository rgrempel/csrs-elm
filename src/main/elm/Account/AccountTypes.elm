module Account.AccountTypes where

import Account.Login.LoginTypes as LoginTypes

type Focus
    = Settings
    | Password
    | Sessions
    | Logout
    | Login LoginTypes.Focus
    | Register

type Action
    = FocusLogin LoginTypes.Action 
    | FocusSettings
    | FocusPassword
    | FocusSessions
    | FocusLogout
    | FocusRegister


