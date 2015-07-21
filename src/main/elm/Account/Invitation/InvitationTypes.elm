module Account.Invitation.InvitationTypes where

import Account.AccountService exposing (UserEmailActivation)
import Http
import Account.Invitation.Register.RegisterTypes as RegisterTypes
import Account.Invitation.ResetPassword.ResetPasswordTypes as ResetPasswordTypes

type Action
    = FocusBlank
    | FocusRegister RegisterTypes.Action
    | FocusResetPassword ResetPasswordTypes.Action
    | FocusKey String
    | CheckInvitation String
    | FocusInvitationNotFound
    | FocusInvitationFound UserEmailActivation
    | FocusError Http.Error

type Status
    = InvitationStart
    | CheckingInvitation
    | InvitationNotFound
    | InvitationFound UserEmailActivation
    | Error Http.Error

type Focus
    = Invitation InvitationFocus
    | Register RegisterTypes.Focus
    | ResetPassword ResetPasswordTypes.Focus

type alias InvitationFocus =
    { key : String
    , status : Status
    }


