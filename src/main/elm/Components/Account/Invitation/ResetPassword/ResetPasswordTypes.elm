module Components.Account.Invitation.ResetPassword.ResetPasswordTypes where

import Account.AccountServiceTypes exposing (UserEmailActivation)

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

