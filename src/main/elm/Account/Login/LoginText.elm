module Account.Login.LoginText where

import Language.LanguageService exposing (Language(..))
import Html exposing (Html, text, span, strong, a)
import Html.Events exposing (onClick)
import Focus.FocusTypes exposing (address, Action(FocusAccount))
import Account.AccountTypes exposing (Action(FocusRegister, FocusResetPassword))
import Account.Register.RegisterTypes as RegisterTypes
import Account.ResetPassword.ResetPasswordTypes as ResetPasswordTypes

type TextMessage
    = UsernamePlaceholder
    | PasswordPlaceholder

type HtmlMessage
    = Failed
    | Succeeded
    | Register
    | Title
    | Username
    | Password
    | RememberMe
    | Button
    | ResetPassword


translateText : Language -> TextMessage -> String
translateText language message =
    case message of
        UsernamePlaceholder -> case language of
            EN -> "Your user name"
            FR -> "Votre nom d'utilisateur"
            LA -> "Nomen usoris tuum"

        PasswordPlaceholder -> case language of
            EN -> "Your password"
            FR -> "Votre mot de passe"
            LA -> "Signum tuum"

            
translateHtml : Language -> HtmlMessage -> Html 
translateHtml language message =
    case message of
        Title -> text <| case language of
            EN -> "Login"
            FR -> "Authentification"
            LA -> "Authenticas"

        Username -> text <| case language of
            EN -> "Username"
            FR -> "Nom d'utilisateur"
            LA -> "Nomen usoris"

        Password -> text <| case language of
            EN -> "Password"
            FR -> "Mot de passe"
            LA -> "Signum"

        RememberMe -> text <| case language of
            EN -> "In future, login automatically from this computer"
            FR -> "Garder la session ouverte"
            LA -> "Cosignum automatic"

        Button -> text <| case language of
            EN -> "Login"
            FR -> "Connexion"
            LA -> "Cosignum"

        Failed -> span [] <| case language of 
            EN -> 
                [ strong [] [ text "Authentication failed!" ]
                , text " Please check your credentials and try again."
                ]
            
            FR ->
                [ strong [] [ text "Erreur d'authentification!" ]
                , text " Veuillez vérifier vos identifiants de connexion."
                ]

            LA ->
                [ strong [] [ text "Defecit authenticitate!" ]
                , text " Probā signum atque iterum cosignio."
                ]

        Succeeded -> text <| case language of
            EN -> "Login succeeded."
            FR -> "L'authentification réussi."
            LA -> "Authenticas successit."

        Register ->
            let
                action =
                    onClick address <| FocusAccount <| FocusRegister RegisterTypes.FocusBlank 
           
            in
                span [] <| case language of
                    EN ->
                        [ text "Don't have an account yet? "
                        , a [ action ]
                            [ text "Register a new account." ]
                        ]

                    FR ->
                        [ text "Vous n'avez pas encore de compte? "
                        , a [ action ]
                            [ text "Créer un compte." ]
                        ]

                    LA ->
                        [ text "Sed non tamen tesseram? "
                        , a [ action ]
                            [ text "Subsigno tesseram novam." ]
                        ]
        
        ResetPassword ->
            let
                action =
                    onClick address <| FocusAccount <| FocusResetPassword ResetPasswordTypes.FocusBlank

            in
                span [] <| case language of
                    EN ->
                        [ text 
                            "If you have forgotten your username or password,
                            then try the "
                        , a [ action ] [ text "password reset" ]
                        , text " page."
                        ]
                    FR ->
                        [ text
                            "Si vous avez oublié le nom d'utilisateur ou mot de
                            passe, puis essayez le "
                        , a [ action ] [ text "mot de passe réinitialiser." ]
                        ]
                    LA ->
                        [ text "Iam obliti usoris aut signo, tum istoc " 
                        , a [ action ] [ text "signum retexere." ]
                        ]

