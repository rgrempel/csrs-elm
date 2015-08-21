module Components.Account.ResetPassword.ResetPasswordTypes where

import Language.LanguageTypes exposing (Language)
import Http

type Action
    = FocusBlank
    | FocusEmail String
    | FocusToken String
    | FocusTokenSent
    | FocusSendTokenError Http.Error
    | SendToken String Language
    | UseToken String

type Status
    = Start
    | Sending
    | Sent
    | Using
    | Used
    | ErrorSending Http.Error

type alias Focus =
    { status : Status
    , email : String
    , token : String
    }


