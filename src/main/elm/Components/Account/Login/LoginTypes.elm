module Components.Account.Login.LoginTypes where

import Account.AccountServiceTypes exposing (Credentials, LoginError)

type Action
    = FocusUserName String
    | FocusPassword String
    | FocusRememberMe Bool
    | FocusBlank
    | FocusLoginError LoginError
    | AttemptLogin Credentials

type Status
    = Start 
    | LoggingIn 
    | LoggedIn
    | Error LoginError

type alias Focus =
    { credentials: Credentials
    , status: Status
    }


