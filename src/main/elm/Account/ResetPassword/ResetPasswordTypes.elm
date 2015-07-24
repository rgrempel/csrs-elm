module Account.ResetPassword.ResetPasswordTypes where

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

type ResetPasswordStatus
    = ResetPasswordStart
    | SendingToken
    | TokenSent
    | UsingToken
    | TokenUsed

type alias Focus =
    { resetPasswordStatus : ResetPasswordStatus
    , email : String
    , token : String
    }


