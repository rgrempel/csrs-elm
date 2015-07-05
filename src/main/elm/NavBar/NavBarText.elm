module NavBar.NavBarText where

import Language.LanguageService exposing (Language(EN, FR, LA))
import Html exposing (Html, text)

type Message
    = ToggleNavigation
    | Title

{-
    | Language
    | Home
    | Account
    | Settings
    | Password
    | Sessions
    | Login
    | Logout
    | Register
-}

translate : Language -> Message -> Html
translate language message =
    text <|
        case message of
            ToggleNavigation -> case language of
                EN -> "Toggle Navigation"
                FR -> "Basculer navigation"
                LA -> "Navigationem inverto"

            Title -> case language of
                EN -> "CSRS Membership"
                FR -> "SCÉR adhésion"
                LA -> "Sodalitas SCSR"

{-
            Language -> case language of
                EN -> "Language"
                FR -> "Langue"
                LA -> "Lingua"

            Home -> case language of
                EN -> "Home"
                FR -> "Accueil"
                LA -> "Domus"

            Account -> case language of 
                EN -> "Account"
                FR -> "Compte"
                LA -> "Tessera"


            Login -> case language of
                EN -> "Authenticate"
                FR -> "S'authentifier"
                LA -> "Cosigno"
-}


{-
        menu: 

            entities: 
                main:
                    en: "Entities"
                    fr: "Entités"
                    la: "Entities"

                contact:
                    en: "Contact"
                    fr: "Contact"
                    la: "Socium"

                annual:
                    en: "Annual"
                    fr: "Annual"
                    la: "Annum"

                additionalEntity:
                    en: "JHipster will add addtional entities"
                    fr: "JHipster will add addtional entities"
                    la: "JHipster will add addtional entities"
            
            
            tasks: 
                main:
                    en: "Tasks"
                    fr: "Tâches"
                    la: "Negotium"

                processForms:
                    en: "Process Forms"
                    fr: "Traiter les formulaires"
                    la: "Formae processum"
            
                membershipByYear:
                        en: Membership by Year
                        fr: Adhésion par année
                        la: Sodalitas per annos
            
            admin: 
                main:
                    en: "Administration"
                    fr: "Administration"
                    la: "Administrationis"

                tracker:
                    en: "User tracker"
                    fr: "Suivi des utilisateurs"
                    la: "User tracker"

                metrics:
                    en: "Metrics"
                    fr: "Métriques"
                    la: "Mensuras"

                health:
                    en: "Health"
                    fr: "Diagnostics"
                    la: "Salutem"

                configuration:
                    en: "Configuration"
                    fr: "Configuration"
                    la: "Configuration"

                logs:
                    en: "Logs"
                    fr: "Logs"
                    la: "Acta"

                audits:
                    en: "Audits"
                    fr: "Audits"
                    la: "Compoto"

                apidocs:
                    en: "API"
                    fr: "API"
                    la: "API"

                database:
                    en: "Database"
                    fr: "Base de données"
                    la: "Database"
            
            language:
                en: "Language"
                fr: "Langue"
                la: "Lingua"

-}
