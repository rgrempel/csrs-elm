module Components.Account.Logout.LogoutTypes where

import Http exposing (Error)

type Action
    = FocusBlank
    | FocusError Error
    | FocusSuccess
    | AttemptLogout

type Status
    = Start
    | LoggingOut
    | LoggedOut
    | Error Error

type alias Focus =
    { status: Status
    }
