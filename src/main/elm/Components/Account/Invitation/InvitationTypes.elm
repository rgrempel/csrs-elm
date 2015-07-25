module Components.Account.Invitation.InvitationTypes where

import Account.AccountServiceTypes exposing (UserEmailActivation)
import Components.Account.Invitation.Register.RegisterTypes as RegisterTypes
import Components.Account.Invitation.ResetPassword.ResetPasswordTypes as ResetPasswordTypes
import Http


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


registerFocus : Focus -> Maybe RegisterTypes.Focus
registerFocus focus =
    case focus of
        Register subfocus -> Just subfocus
        _ -> Nothing


resetPasswordFocus : Focus -> Maybe ResetPasswordTypes.Focus
resetPasswordFocus focus =
    case focus of
        ResetPassword subfocus -> Just subfocus
        _ -> Nothing

