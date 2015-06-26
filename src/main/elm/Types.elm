module Types where

import Translation.Model exposing (Language)
import Focus.Types exposing (Focus, DesiredLocation)
import Account.Login.Model exposing (Credentials)

type Action
    = NoOp
    | SwitchLanguage Language
    | SwitchFocus Focus
    | SwitchFocusFromPath Focus
    | AttemptLogin Credentials

type alias Model =
    { useLanguage : Language
    , focus : Focus
    , desiredLocation : Maybe DesiredLocation
    }

