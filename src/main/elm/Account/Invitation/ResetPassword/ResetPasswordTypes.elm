module Account.Invitation.ResetPassword.ResetPasswordTypes where

import Language.LanguageService exposing (Language)
import Http
import Account.AccountService exposing (UserEmailActivation)

type Action
    = FocusActivation UserEmailActivation
    | FocusPassword String
    | FocusConfirmPassword String
    | FocusUserName String
    | FocusStatus Status

type Status
    = Start

type alias Focus =
    { status : Status
    , password : String
    , confirmPassword : String
    , userName : String
    , activation : UserEmailActivation
    }

