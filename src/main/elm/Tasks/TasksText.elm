module Tasks.TasksText where

import Language.LanguageService exposing (Language(..))
import Html exposing (Html, text, span, strong, a)

type Message
    = Title
    -- Split out eventually
    | ProcessForms 
    | MembershipByYear


translate : Language -> Message -> Html
translate language message =
    text <| case message of
        Title -> case language of
            EN -> "Tasks"
            FR -> "Tâches"
            LA -> "Negotium"
        
        -- Will split out
        ProcessForms -> case language of
            EN -> "Process Forms"
            FR -> "Traiter les formulaires"
            LA -> "Formae processum"


        MembershipByYear -> case language of
            EN -> "Membership by Year"
            FR -> "Adhésion par année"
            LA -> "Sodalitas per annos"


