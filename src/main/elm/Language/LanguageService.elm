module Language.LanguageService where

import Signal exposing (Mailbox, mailbox)
import Json.Decode exposing (Decoder, string, andThen, succeed, fail)
import Json.Encode as JE
import String exposing (toUpper)
import Task exposing (Task)


type Language =
    EN | FR | LA

type Action
    = SwitchLanguage Language
    | NoOp

type alias Model m = { m
    | useLanguage : Language
}


do : Action -> Task x ()
do = Signal.send actions.address


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


encode : Language -> JE.Value
encode language =
    JE.string <|
        case language of
            EN -> "en"
            FR -> "fr"
            LA -> "la"


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
