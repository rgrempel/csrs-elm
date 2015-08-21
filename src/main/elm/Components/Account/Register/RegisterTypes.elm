module Components.Account.Register.RegisterTypes where

import Language.LanguageTypes exposing (Language)
import Http

type Action
    = FocusBlank
    | FocusEmail String
    | FocusInvitation String
    | FocusInvitationSent
    | FocusSendInvitationError Http.Error
    | SendInvitation String Language
    | UseInvitation String

type Status
    = Start
    | Sending
    | Sent
    | Using
    | Used

type alias Focus =
    { status : Status
    , email : String
    , invitation : String
    }

