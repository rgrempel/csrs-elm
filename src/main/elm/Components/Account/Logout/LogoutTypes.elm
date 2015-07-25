module Components.Account.Logout.LogoutTypes where

import Http exposing (Error)

type Action
    = FocusBlank
    | FocusError Error
    | FocusSuccess
    | AttemptLogout

type LogoutStatus
    = LogoutNotAttempted
    | LogoutInProgress
    | LogoutSuccess
    | LogoutError Error

type alias Focus =
    { logoutStatus: LogoutStatus
    }
