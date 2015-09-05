module Language.LanguageTypes where

import Signal exposing (Mailbox, mailbox)
import Json.Decode exposing (Decoder, string, andThen, succeed, fail, customDecoder)
import Json.Encode as JE
import String exposing (toUpper)
import Result exposing (Result(..))
import Task exposing (Task)
import Date exposing (Date)
import Date.Op exposing (formatWithDict, stdTokens)
import Date.Locale.EN
import Date.Locale.FR
import Date.Locale.LA


type Language =
    EN | FR | LA

type Action
    = SwitchLanguage Language
    | NoOp

type alias LanguageModel =
    { useLanguage : Language
    , formatDate : String -> Date -> String
    }


allLanguages : List Language
allLanguages = [EN, FR, LA]


defaultLanguage : Language
defaultLanguage = EN


initialModel : LanguageModel
initialModel = LanguageModel defaultLanguage (dateFormatter defaultLanguage)


dateFormatter : Language -> String -> Date -> String
dateFormatter language =
    case language of
        EN ->
            formatWithDict <| Date.Locale.EN.localize stdTokens 

        FR ->
            formatWithDict <| Date.Locale.FR.localize stdTokens 

        LA ->
            formatWithDict <| Date.Locale.LA.localize stdTokens 


fromString : String -> Result String Language
fromString s =
    case (toUpper s) of
        "EN" ->
            Ok EN

        "LA" ->
            Ok LA

        "FR" ->
            Ok FR

        _ ->
            Err <| s ++ " is not a language I recognize"


decoder : Decoder Language
decoder = customDecoder string fromString


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


