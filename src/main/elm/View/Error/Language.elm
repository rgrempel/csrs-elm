module View.Error.Language where

import Model.Translation exposing (Language(EN, FR, LA))
import Html exposing (Html, text)

type Message
    = Title 

translate : Language -> Message -> Html
translate language message =
    text <|
        case message of
            Title -> case language of
                EN -> "Error page!"
                FR -> "Page d'erreur!"
                LA -> "Paginam erratam!"