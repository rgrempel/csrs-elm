module View.Home.Language where

import Model.Translation exposing (Language(EN, FR, LA))
import Html exposing (Html, text)

type Message
    = Title 
    | Subtitle

translate : Language -> Message -> Html
translate language message =
    text <|
        case message of
            Title -> case language of
                EN -> "Welcome, Renaissance Scholar!"
                FR -> "Bienvenue, érudit de la Renaissance!"
                LA -> "Scolaris de renaissance, exspectata!"

            Subtitle -> case language of
                EN -> "This is the Canadian Society for Renaissance Studies membership site."
                FR -> "Ce est le site d'adhésion de la Société canadienne d'études de la Renaissance."
                LA -> "Hic situs sociari de Societate Canadian Studiorum Renascerentur."
