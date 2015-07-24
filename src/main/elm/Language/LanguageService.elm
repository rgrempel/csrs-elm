module Language.LanguageService where

import AppTypes exposing (..)
import Language.LanguageTypes exposing (..)


update : Action -> Model -> Model
update action model =
    case action of
        -- TODO: Should generate a reaction to update the language preference on the server
        SwitchLanguage language ->
            { model | useLanguage <- language }

        _ ->
            model
