module Language.LanguageService where

import AppTypes exposing (..)
import Language.LanguageTypes exposing (..)


submodule : SubModule x (LanguageModel x) Action
submodule =
    { initialModel = initialModel
    , actions = .signal actions
    , update = update
    , reaction = Nothing
    , initialTask = Nothing
    }


update : Action -> LanguageModel x -> LanguageModel x
update action model =
    case action of
        -- TODO: Should generate a reaction to update the language preference on the server
        SwitchLanguage language ->
            { model
                | useLanguage <- language
                , formatDate <- dateFormatter language
            }

        _ ->
            model
