module Account.Register.RegisterTypes where

import Language.LanguageService exposing (Language)
import Http

type Action
    = FocusBlank
    | FocusEmail String
    | FocusInvitation String
    | FocusInvitationSent
    | FocusSendInvitationError Http.Error
    | SendInvitation String Language
    | UseInvitation String

type RegisterStatus
    = RegistrationStart
    | SendingInvitation
    | InvitationSent
    | UsingInvitation
    | IntivationUsed

type alias Focus =
    { registerStatus : RegisterStatus
    , email : String
    , invitation : String
    }

