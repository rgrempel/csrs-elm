module Account.Login.LoginTypes where

import Account.AccountService as AccountService exposing (Credentials, Action(AttemptLogin), LoginResult(WrongPassword))

type Action
    = FocusUserName String
    | FocusPassword String
    | FocusRememberMe Bool
    | FocusBlank
    | FocusLoginResult LoginResult

type alias Focus =
    { credentials: Credentials
    , loginResult: Maybe LoginResult
    }


