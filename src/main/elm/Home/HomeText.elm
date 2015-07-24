module Home.HomeText where

import Language.LanguageTypes exposing (Language(EN, FR, LA))
import Html exposing (Html, text, span, a, strong)
import Html.Attributes exposing (href, target)
import Html.Events exposing (onClick)
import Focus.FocusTypes exposing (address, Action(FocusAccount))
import Account.AccountTypes exposing (Action(FocusLogin, FocusRegister))
import Account.Login.LoginTypes as LoginTypes exposing (Action(FocusBlank))
import Account.Register.RegisterTypes as RegisterTypes exposing (Action(FocusBlank))


type Message
    = Title 
    | Subtitle
    | MenuItem
    | LoggedInAs String
    | CheckMembershipInformation
    | BeenHereBefore
    | NoAccount
    | MoreInformation


translate : Language -> Message -> Html
translate language message =
    case message of
        Title -> text <| case language of
            EN -> "Welcome, Renaissance Scholar!"
            FR -> "Bienvenue, érudit de la Renaissance!"
            LA -> "Scolaris de renaissance, exspectata!"

        Subtitle -> text <| case language of
            EN -> "This is the Canadian Society for Renaissance Studies membership site."
            FR -> "Ce est le site d'adhésion de la Société canadienne d'études de la Renaissance."
            LA -> "Hic situs sociari de Societate Canadian Studiorum Renascerentur."
        
        MenuItem -> text <| case language of
            EN -> "Home"
            FR -> "Accueil"
            LA -> "Domus"

        LoggedInAs user -> text <| case language of
            EN -> "You are logged in as user \"" ++ user ++ "\"."
            FR -> "Vous êtes connecté en tant que \"" ++ user ++ "\"."
            LA -> "Te \"" ++ user ++ "\" videntur esse."

        CheckMembershipInformation -> text <| case language of
            EN -> "Check your membership information"
            FR -> "Vérifiez les informations d'adhésion"
            LA -> "Reprehendo vestri notitia sodalitas"

        MoreInformation ->
            let
                link =
                    a [ href "http://csrs-scer.ca/", target "_blank" ] 
                      [ text "http://csrs-scer.ca/" ]

            in
                case language of
                    EN ->
                        span []
                            [ text "For more information about the "
                            , strong [] [text "Canadian Society for Renaissance Studies"]
                            , text ", see our main website, at "
                            , link
                            ]
                    FR ->
                        span []
                            [ text "Pour plus d'informations sur le "
                            , strong [] [text "Société canadienne d'études de la Renaissance"]
                            , text ", consultez notre site Web principal, au "
                            , link 
                            ]

                    LA ->
                        span []
                            [ text "Pro magis notitia de "
                            , strong [] [text "Societate Canadian Studiorum Renascerentur"]
                            , text ", ite situm principale ad "
                            , link
                            ]

        BeenHereBefore ->
            let
                loginLink =
                    onClick address <| FocusAccount <| FocusLogin LoginTypes.FocusBlank 

            in
                case language of
                    EN ->    
                        span []
                            [ text "Been here before? "
                            , a [ loginLink ]
                                [ text "Login with your account." ]
                            ]
                    FR -> 
                        span []
                            [ text "Vous connaissez cet endroit? "
                            , a [ loginLink ]
                                [ text "Connecter avec votre compte." ]
                            ]

                    LA ->
                        span []
                            [ text "Numquid hie fuerunt prius? "
                            , a [ loginLink ]
                                [ text "Cosigno in tesseram vestram." ]
                            ]

        NoAccount ->
            let
                link =
                    onClick address <| FocusAccount <| FocusRegister RegisterTypes.FocusBlank

            in
                case language of
                    EN ->
                        span []
                            [ text "Don't have an account yet? "
                            , a [ link ]
                                [ text "Register a new account." ]
                            ]

                    FR ->
                        span []
                            [ text "Vous n'avez pas encore de compte? "
                            , a [ link ]
                                [ text "Créer un compte." ]
                            ]

                    LA ->
                        span []
                            [ text "Sed non tamen tesseram? "
                            , a [ link ]
                                [ text "Subsigno tesseram novam." ]
                            ]

