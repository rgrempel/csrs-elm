module Components.NavBar.NavBarText where

import Language.LanguageTypes exposing (Language(..))
import Html exposing (Html, text)


type Message
    = ToggleNavigation
    | Title


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

