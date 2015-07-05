module Language.LanguageService where

import Signal exposing (Mailbox, mailbox)

type Language = EN | FR | LA

type Action
    = SwitchLanguage Language
    | NoOp

type alias Model m =
    { m
        | useLanguage : Language
    }


init : m -> Model m
init model =
    { model
        | useLanguage = defaultLanguage
    }


allLanguages : List Language
allLanguages = [EN, FR, LA]


defaultLanguage : Language
defaultLanguage = EN


service : Mailbox Action
service = mailbox NoOp


update : Action -> Model m -> Model m
update action model =
    case action of
        SwitchLanguage language ->
            { model | useLanguage <- language }

        _ ->
            model
