module Account.Invitation.InvitationTypes where

import Account.AccountService exposing (UserEmailActivation)
import Http

type Action
    = FocusBlank
    | FocusKey String
    | CheckInvitation String
    | FocusInvitationNotFound
    | FocusInvitationFound UserEmailActivation
    | FocusError Http.Error

type InvitationStatus
    = InvitationStart
    | CheckingInvitation
    | InvitationNotFound
    | InvitationFound UserEmailActivation
    | Error Http.Error

type alias Focus =
    { invitationStatus : InvitationStatus
    , key : String
    }


