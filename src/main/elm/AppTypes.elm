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
    { initialModel : x -> submodel
    , actions : Signal superaction
    , update : subaction -> submodel -> submodel
    , reaction : subaction -> submodel -> Maybe (Task () ())
    , initialTask : Maybe (Task () ())
    }


superModule : (subaction -> superaction) -> SubModule x submodel subaction -> SuperModule x submodel subaction superaction
superModule actionTag submodule =
    { initialModel = submodule.initialModel
    , actions = Signal.map actionTag submodule.actions
    , update = submodule.update
    , reaction subaction submodel = submodule.reaction `Maybe.andThen` \reaction -> reaction subaction submodel
    , initialTask = submodule.initialTask
    }

