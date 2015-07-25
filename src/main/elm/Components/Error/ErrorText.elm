module Components.Error.ErrorText where

import Language.LanguageTypes exposing (Language(..))
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
