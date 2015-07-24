module Account.Invitation.Register.RegisterText where

import Language.LanguageTypes exposing (Language(..))
import Html exposing (Html, text, span, strong, a)


type TextMessage
    = UserNamePlaceholder
    | PasswordPlaceholder
    | ConfirmPasswordPlaceholder

type HtmlMessage
    = Email
    | UserName
    | NewPassword
    | ConfirmPassword
    | Title
    | Blurb


translateText : Language -> TextMessage -> String
translateText language message =
    case message of
        UserNamePlaceholder -> case language of
            EN -> "Your user name"
            FR -> "Votre nom d'utilisateur"
            LA -> "Nomen usoris tuum"

        PasswordPlaceholder -> case language of
            EN -> "Your password"
            FR -> "Votre mot de passe"
            LA -> "Signum tuum"
        
        ConfirmPasswordPlaceholder -> case language of
            EN -> "Confirm the new password"
            FR -> "Confirmation du nouveau mot de passe"
            LA -> "Signum novum confirmatio"

            
translateHtml : Language -> HtmlMessage -> Html 
translateHtml language message =
    text <| case message of
        Title -> case language of
            EN -> "Create Account"
            FR -> "Création de compte utilisateur"
            LA -> "Tesseram creare"

        Blurb -> case language of
            EN ->
                """
                To create your account, provide whatever username and password
                you would like to use.
                """
            FR ->
                """
                Pour créer votre compte, fournir toutes les nom d'utilisateur
                et mot de passe vous souhaitez utiliser.
                """
            LA ->
                """
                Tesseram creare, provideat nomine usoris et signum vos amo
                utor.
                """

        Email -> case language of
            EN -> "Email Address"
            FR -> "Email"
            LA -> "Inscriptio electronica"

        NewPassword -> case language of
            EN -> "New password"
            FR -> "Nouveau mot de passe"
            LA -> "Signum novum"
        
        ConfirmPassword -> case language of
            EN -> "New password confirmation"
            FR -> "Confirmation du nouveau mot de passe"
            LA -> "Signum novum confirmatio"

        UserName -> case language of
            EN -> "Username"
            FR -> "Nom d'utilisateur"
            LA -> "Nomen usoris"
