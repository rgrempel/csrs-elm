module Components.Account.Sessions.SessionsText where

import Language.LanguageTypes exposing (Language(..))
import Html exposing (Html, text, span, strong, a)
import Html.Events exposing (onClick)

type Message
    = Title String
    | Sessions
    | IPAddress
    | UserAgent
    | Date
    | Invalidate
    | Success


translate : Language -> Message -> Html 
translate language message =
    case message of
        Sessions -> text <| case language of
            EN -> "Sessions"
            FR -> "Sessions"
            LA -> "Sessions"

        Title username -> case language of
            EN ->
                span []
                    [ text "Active sessions for ["
                    , strong [] [ text username ]
                    , text "]"
                    ]
            FR -> 
                span []
                    [ text "Sessions actives de ["
                    , strong [] [ text username ]
                    , text "]"
                    ]
            LA ->
                span []
                    [ text "Active sessions for ["
                    , strong [] [ text username ]
                    , text "]"
                    ]

        IPAddress -> text <| case language of
            EN -> "IP address"
            FR -> "Adresse IP"
            LA -> "IP address"

        UserAgent -> text <| case language of
            EN -> "User Agent"
            FR -> "User Agent"
            LA -> "User Agent"

        Date -> text <| case language of
            EN -> "Date"
            FR -> "Date"
            LA -> "Date"

        Invalidate -> text <| case language of
            EN -> "Invalidate"
            FR -> "Invalider"
            LA -> "Invalidate"
    
        Success -> text <| case language of
            EN -> "Session invalidated!"
            FR -> "Session a été invalidée!"
            LA -> "Session invalidated!"


