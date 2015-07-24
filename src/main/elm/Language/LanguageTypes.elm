module Language.LanguageTypes where

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

type alias LanguageModel m =
    { m | useLanguage : Language }


allLanguages : List Language
allLanguages = [EN, FR, LA]


defaultLanguage : Language
defaultLanguage = EN


initialModel : m -> LanguageModel m
initialModel model = LanguageModel defaultLanguage model


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


actions : Mailbox Action
actions = mailbox NoOp


do : Action -> Task x ()
do = Signal.send actions.address


