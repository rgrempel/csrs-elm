module Components.Account.AccountText where

import Language.LanguageTypes exposing (Language(..))
import Html exposing (Html, text, span, strong, a)

type Message
    = Title
    -- Split out eventually
    | Settings
    | Sessions


translate : Language -> Message -> Html
translate language message =
    text <| case message of
        Title -> case language of
            EN -> "Account"
            FR -> "Compte"
            LA -> "Tessera"
        
        -- These will get split out eventually
        Settings -> case language of
            EN -> "Settings"
            FR -> "Profil"
            LA -> "Optiones"

        Sessions -> case language of
            EN -> "Sessions"
            FR -> "Sessions"
            LA -> "Sessiones"
 
