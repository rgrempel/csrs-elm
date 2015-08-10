module Components.Account.Invitation.ResetPassword.ResetPasswordTypes where

import Account.AccountServiceTypes exposing (UserEmailActivation, LoginError)
import Http exposing (Error)


type Action
    = FocusActivation UserEmailActivation
    | FocusPassword String
    | FocusConfirmPassword String
    | ResetPassword String String UserEmailActivation
    | FocusError Error
    | FocusLoginError LoginError

type Status
    = Start
    | ResettingPassword
    | Error Error
    | LoginError LoginError

type alias Focus =
    { status : Status
    , password : String
    , confirmPassword : String
    , activation : UserEmailActivation
    }

