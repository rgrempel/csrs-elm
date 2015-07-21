module Account.Invitation.Register.RegisterTypes where

import Language.LanguageService exposing (Language)
import Http
import Account.AccountService exposing (UserEmailActivation)

type Action
    = FocusActivation UserEmailActivation
    | FocusPassword String
    | FocusConfirmPassword String
    | FocusUserName String
    | FocusRegisterStatus RegisterStatus

type RegisterStatus
    = RegisterStart

type alias Focus =
    { registerStatus : RegisterStatus
    , password : String
    , confirmPassword : String
    , userName : String
    , activation : UserEmailActivation
    }

