module Action where

import Model.Translation exposing (Language)
import Model.Focus exposing (Focus)
import Model.Login exposing (Credentials)

type Action
    = NoOp
    | SwitchLanguage Language
    | SwitchFocus Focus
    | SwitchFocusFromPath Focus
    | AttemptLogin Credentials


