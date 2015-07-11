module Admin.AdminText where

import Language.LanguageService exposing (Language(..))
import Html exposing (Html, text, span, strong, a)

type Message
    = Title
    -- Split out eventually
    | Metrics 
    | Health
    | Configuration
    | Logs
    | Audits
    | ApiDocs
    | Templates
    | Images


translate : Language -> Message -> Html
translate language message =
    text <| case message of
        Title -> case language of
            EN -> "Administration"
            FR -> "Administration"
            LA -> "Administrationis"
        
        -- Will split out
        Metrics -> case language of
            EN -> "Metrics"
            FR -> "Métriques"
            LA -> "Mensuras"

        Health -> case language of
            EN -> "Health"
            FR -> "Diagnostics"
            LA -> "Salutem"

        Configuration -> case language of
            EN -> "Configuration"
            FR -> "Configuration"
            LA -> "Configuration"

        Logs -> case language of
            EN -> "Logs"
            FR -> "Logs"
            LA -> "Acta"

        Audits -> case language of
            EN -> "Audits"
            FR -> "Audits"
            LA -> "Compoto"

        ApiDocs -> case language of
            EN -> "API"
            FR -> "API"
            LA -> "API"

        Templates -> case language of
            EN -> "Templates"
            FR -> "Gabarit"
            LA -> "Exemplaria"

        Images -> case language of
            EN -> "Images"
            FR -> "Images"
            LA -> "Imago"



