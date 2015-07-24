module Html.UtilText where

import Language.LanguageTypes exposing (Language(..))
import Html exposing (Html, text, span, strong, a)
import Http exposing (Error(..))


translate : Language -> Error -> Html
translate language error =
    text <| case error of
        Timeout -> case language of
            EN -> "Timeout"
            FR -> "Timeout"
            LA -> "Timeout"
        
        NetworkError -> case language of
            EN -> "Network Error"
            FR -> "Network Error"
            LA -> "Network Error"

        UnexpectedPayload _ -> case language of
            EN -> "Unexpected Payload"
            FR -> "Unexpected Payload"
            LA -> "Unexpected Payload"

        BadResponse _ _ -> case language of
            EN -> "Bad Response"
            FR -> "Bad Response"
            LA -> "Bad Response"
