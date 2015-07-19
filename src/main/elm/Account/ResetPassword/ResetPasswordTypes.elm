module Account.ResetPassword.ResetPasswordTypes where

type Action
    = FocusBlank

type ResetPasswordStatus
    = ResetPasswordNotAttempted
    | TokenSent

type alias Focus =
    { resetPasswordStatus : ResetPasswordStatus
    }


