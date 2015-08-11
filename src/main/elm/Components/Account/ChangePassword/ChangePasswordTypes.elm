module Components.Account.ChangePassword.ChangePasswordTypes where

import Account.AccountServiceTypes exposing (LoginError)

type Action
    = FocusOldPassword String
    | FocusNewPassword String
    | FocusConfirmPassword String
    | FocusBlank
    | FocusSuccess
    | FocusError LoginError
    | ChangePassword String String String

type Status
    = Start 
    | ChangingPassword
    | Success
    | Error LoginError

type alias Focus =
    { oldPassword : String
    , newPassword : String
    , confirmPassword : String
    , status : Status
    }

