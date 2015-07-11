module Language.LanguageService where

import Signal exposing (Mailbox, mailbox)
import Json.Decode exposing (Decoder, string, andThen, succeed, fail)
import String exposing (toUpper)


type Language =
    EN | FR | LA

type Action
    = SwitchLanguage Language
    | NoOp

type alias Model m = { m
    | useLanguage : Language
}


init : m -> Model m
init model = Model defaultLanguage model


decoder : Decoder Language
decoder =
    string `andThen` \s ->
        case (toUpper s) of
            "EN" ->
                succeed EN

            "LA" ->
                succeed LA

            "FR" ->
                succeed FR

            _ ->
                fail <| s ++ " is not a language I recognize"


allLanguages : List Language
allLanguages = [EN, FR, LA]


defaultLanguage : Language
defaultLanguage = EN


actions : Mailbox Action
actions = mailbox NoOp


update : Action -> Model m -> Model m
update action model =
    case action of
        SwitchLanguage language ->
            { model | useLanguage <- language }

        _ ->
            model
