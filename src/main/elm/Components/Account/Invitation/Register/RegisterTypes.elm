module Components.Account.Invitation.Register.RegisterTypes where

import Account.AccountServiceTypes exposing (UserEmailActivation, LoginError, CreateAccountError)
import Language.LanguageTypes exposing (Language)
import Dict exposing (Dict)


type Action
    = FocusActivation UserEmailActivation
    | FocusPassword String
    | FocusConfirmPassword String
    | FocusUserName String
    | CheckUserName String
    | FocusUserExists String Bool
    | CreateAccount AccountInfo UserEmailActivation Language
    | FocusError CreateAccountError 
    | FocusLoginError LoginError

type RegisterStatus
    = RegisterStart
    | CreatingAccount
    | CreationError CreateAccountError 
    | LoginError LoginError

type alias AccountInfo =
    { username : String
    , password : String
    , confirmPassword : String
    }

type alias Focus =
    { status : RegisterStatus
    , accountInfo : AccountInfo
    , users : Dict String Bool
    , activation : UserEmailActivation
    }

