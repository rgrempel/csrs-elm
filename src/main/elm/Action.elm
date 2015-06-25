module Action where

import Model.Translation exposing (Language)
import Model.Focus exposing (Focus)

type Action
    = NoOp
    | SwitchLanguage Language
    | SwitchFocus Focus
    | SwitchFocusFromPath Focus


