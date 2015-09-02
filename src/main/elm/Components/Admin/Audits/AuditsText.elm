module Components.Admin.Audits.AuditsText where

import Language.LanguageTypes exposing (Language(..))
import Html exposing (Html, text, span, strong, a)


type Message
    = Title
    | FilterTitle
    | FilterFrom
    | FilterTo
    | FilterButtonWeeks
    | FilterButtonToday
    | FilterButtonClear
    | FilterButtonClose
    | TableHeaderPrincipal
    | TableHeaderDate
    | TableHeaderStatus
    | TableHeaderData
    | TableDataRemoteAddress


translate : Language -> Message -> Html
translate language message =
    text <| case message of
        Title -> case language of
            EN -> "Audits"
            FR -> "Audits"
            LA -> "Compoto"
    
        FilterTitle -> case language of 
            EN -> "Filter per date"
            FR -> "Filtrer par date"
            LA -> "Filter per date"

        FilterFrom -> case language of
            EN -> "from"
            FR -> "De"
            LA -> "from"

        FilterTo -> case language of
            EN -> "to"
            FR -> "à"
            LA -> "to"

        FilterButtonWeeks -> case language of
            EN -> "Weeks"
            FR -> "Semaines"
            LA -> "Weeks"

        FilterButtonToday -> case language of
            EN -> "today"
            FR -> "Aujourd'hui"
            LA -> "today"

        FilterButtonClear -> case language of
            EN -> "clear"
            FR -> "Effacer"
            LA -> "clear"

        FilterButtonClose -> case language of
            EN -> "close"
            FR -> "Fermer"
            LA -> "close"
        
        TableHeaderPrincipal -> case language of
            EN -> "User"
            FR -> "Utilisateur"
            LA -> "User"

        TableHeaderDate -> case language of
            EN -> "Date"
            FR -> "Date"
            LA -> "Date"

        TableHeaderStatus -> case language of
            EN -> "State"
            FR -> "Status"
            LA -> "State"

        TableHeaderData -> case language of
            EN -> "Extra data"
            FR -> "Autres données"
            LA -> "Extra data"
            
        TableDataRemoteAddress -> case language of
            EN -> "Remote Address:"
            FR -> "Adresse Distante:"
            LA -> "Remote Address:"

