module AppTypes where

import Language.LanguageTypes exposing (LanguageModel)
import Account.AccountServiceTypes exposing (AccountModel)
import Components.FocusTypes exposing (FocusModel)


{-| The big model ...

Note that we don't define any of the substance of the model at this highest
level.  Instead, we just collect model definitions from modules that define
model stuff.

-}
type alias Model =
    LanguageModel (
    AccountModel (
    FocusModel (
      {}
    )))
