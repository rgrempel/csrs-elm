module Account.PasswordStrengthBar.PasswordStrengthBarText where

import Language.LanguageService exposing (Language(..))
import Html exposing (Html, text, span, strong, a)

type Message
    = PasswordStrength

translate : Language -> Message -> Html
translate language message =
    case message of
        PasswordStrength -> text <| case language of
            EN -> "Password strength:"
            FR -> "Robustesse du mot de passe:"
            LA -> "Fortitudo signum:"
