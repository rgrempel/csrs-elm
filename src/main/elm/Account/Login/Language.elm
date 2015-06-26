module Account.Login.Language where

import Translation.Model exposing (Language(EN, FR, LA))
import Html exposing (Html, text)

type Message
    = Title
    | Username
    | UsernamePlaceholder
    | Password
    | PasswordPlaceholder
    | RememberMe
    | Button

translate : Language -> Message -> String
translate language message =
    case message of
        Title -> case language of
            EN -> "Authentication"
            FR -> "Authentification"
            LA -> "Authenticas"

        Username -> case language of
            EN -> "Username"
            FR -> "Nom d'utilisateur"
            LA -> "Nomen usoris"

        UsernamePlaceholder -> case language of
            EN -> "Your user name"
            FR -> "Votre nom d'utilisateur"
            LA -> "Nomen usoris tuum"
        
        Password -> case language of
            EN -> "Password"
            FR -> "Mot de passe"
            LA -> "Signum"

        PasswordPlaceholder -> case language of
            EN -> "Your password"
            FR -> "Votre mot de passe"
            LA -> "Signum tuum"

        RememberMe -> case language of
            EN -> "Automatic Login"
            FR -> "Garder la session ouverte"
            LA -> "Cosignum automatic"

        Button -> case language of
            EN -> "Authenticate"
            FR -> "Connexion"
            LA -> "Cosignum"

translateHtml : Language -> Message -> Html
translateHtml language message =
    text <| translate language message

{-
            
            messages: 
                error: 
                    authentication:
                        en: "<strong>Authentication failed!</strong> Please check your credentials and try again."
                        fr: "<strong>Erreur d'authentification!</strong> Veuillez vérifier vos identifiants de connexion."
                        la: "<strong>Defecit authenticitate!</strong> Probā signum atque iterum cosignio."
                info:
                    register:
                        en: "Don't have an account yet? <a href=\"#!/account/create\">Register a new account.</a>"
                        fr: "Vous n'avez pas encore de compte? <a href=\"#!/account/create\">Créer un compte.</a>"
                        la: "Sed non tamen tesseram? <a href=\"#!/account/create\">Subsigno tesseram novam.</a>"
-}
