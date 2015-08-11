module Components.Account.ChangePassword.ChangePasswordText where

import Language.LanguageTypes exposing (Language(..))
import Html exposing (Html, text, span, strong, a, b)

type TextMessage
    = OldPasswordPlaceholder
    | NewPasswordPlaceholder
    | ConfirmPasswordPlaceholder

type HtmlMessage
    = Title
    | FullTitle String
    | OldPassword
    | NewPassword
    | ConfirmPassword
    | Failed
    | Success


translateText : Language -> TextMessage -> String
translateText language message =
    case message of
        OldPasswordPlaceholder -> case language of
            EN -> "Current password"
            FR -> "Mot de passe courant"
            LA -> "Signum praesens"

        NewPasswordPlaceholder -> case language of
            EN -> "New password"
            FR -> "Nouveau mot de passe"
            LA -> "Signum novum"

        ConfirmPasswordPlaceholder -> case language of
            EN -> "Confirm the new password"
            FR -> "Confirmation du nouveau mot de passe"
            LA -> "Signum novum confirmatio"
      

translateHtml : Language -> HtmlMessage -> Html 
translateHtml language message =
    case message of
        Title -> text <| case language of
            EN -> "Change Password"
            FR -> "Changer le mot de passe"
            LA -> "Signum mutatio"

        FullTitle user -> case language of
            EN ->
                span []
                    [ text "Change Password for "
                    , b [] [ text user ]
                    ]
            FR ->
                span []
                    [ text "Changer le mot de passe pour "
                    , b [] [ text user ]
                    ]
            LA ->
                span []
                    [ text "Signum mutatio pro "
                    , b [] [ text user ]
                    ]
    
        OldPassword -> text <| case language of
            EN -> "Current password"
            FR -> "Mot de passe courant"
            LA -> "Signum praesens"

        NewPassword -> text <| case language of
            EN -> "New password"
            FR -> "Nouveau mot de passe"
            LA -> "Signum novum"

        ConfirmPassword -> text <| case language of
            EN -> "New password confirmation"
            FR -> "Confirmation du nouveau mot de passe"
            LA -> "Signum novum confirmatio"


        Failed -> text <| case language of
            EN -> "The password you entered did not match your current password."
            FR -> "Le mot de passe que vous avez saisi ne correspond pas votre mot de passe courant."
            LA -> "Non signum compositus vestri signum praesens."

        Success -> text <| case language of
            EN -> "Password changed!"
            FR -> "La mot de passe a été modifié!"
            LA -> "Signum mutatum!"

