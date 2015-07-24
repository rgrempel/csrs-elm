module Account.Login.LoginTypes where

import Account.AccountServiceTypes exposing (Credentials, LoginError)

type Action
    = FocusUserName String
    | FocusPassword String
    | FocusRememberMe Bool
    | FocusBlank
    | FocusLoginError LoginError
    | AttemptLogin Credentials

type LoginStatus
    = LoginNotAttempted
    | LoginInProgress
    | LoginSuccess
    | LoginError LoginError

type alias Focus =
    { credentials: Credentials
    , loginStatus: LoginStatus
    }


