module Account.AccountText where

import Language.LanguageService exposing (Language(..))
import Html exposing (Html, text, span, strong, a)
import Html.Attributes exposing (href)

type Message
    = Title
    -- Split out eventually
    | Settings
    | Password
    | Sessions
    | Logout
    | Register


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

        Password -> case language of
            EN -> "Password"
            FR -> "Mot de passe"
            LA -> "Signum"

        Sessions -> case language of
            EN -> "Sessions"
            FR -> "Sessions"
            LA -> "Sessiones"
        
        Logout -> case language of
            EN -> "Log out"
            FR -> "Déconnexion"
            LA -> "Conventum concludere"

        Register -> case language of
            EN -> "Register"
            FR -> "Créer un compte"
            LA -> "Subsigno"
