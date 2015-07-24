module Account.Logout.LogoutText where

import Language.LanguageTypes exposing (Language(..))
import Html exposing (Html, text, span, strong, a)


type Message
    = Title
    | LoggingOut


translate : Language -> Message -> Html 
translate language message =
    text <| case message of
        Title -> case language of
            EN -> "Log out"
            FR -> "Déconnexion"
            LA -> "Conventum concludere"

        LoggingOut -> case language of
            EN -> "Logging out"
            FR -> "TODO: Logging out"
            LA -> "TODO: Logging out"


