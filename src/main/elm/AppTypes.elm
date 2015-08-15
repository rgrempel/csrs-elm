module AppTypes where

import Language.LanguageTypes exposing (LanguageModel)
import Account.AccountServiceTypes exposing (AccountModel)
import Components.FocusTypes exposing (FocusModel)

import Task exposing (Task)


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


type alias SubModule x model action =
    { initialModel : x -> model
    , actions : Signal action
    , update : action -> model -> model
    , reaction : Maybe (action -> model -> Maybe (Task () ()))
    , initialTask : Maybe (Task () ())
    }

type alias SuperModule x submodel subaction superaction =
    { actionTag : subaction -> superaction
    , sub : SubModule x submodel subaction
    }

