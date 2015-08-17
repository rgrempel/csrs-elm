module AppTypes where

import Language.LanguageTypes exposing (LanguageModel)
import Account.AccountServiceTypes exposing (AccountModel)
import Components.FocusTypes exposing (FocusModel)
import Route.RouteService as RouteService exposing (PathAction)

import Task exposing (Task)
import Signal exposing (Address, forwardTo)
import Html exposing (Html)
import List exposing (head)


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
    let
        actions =
            Signal.map actionTag submodule.actions

        reaction subaction submodel =
            submodule.reaction
                `Maybe.andThen` \reaction ->
                    reaction subaction submodel
    
    in
        { initialModel = submodule.initialModel
        , actions = actions
        , update = submodule.update
        , reaction = reaction
        , initialTask = submodule.initialTask
        }
        

type alias SubComponent subaction subfocus =
    { route : List String -> Maybe subaction
    , path : Maybe subfocus -> subfocus -> Maybe PathAction
    , reaction : Maybe (Address subaction -> subaction -> Maybe subfocus -> Maybe (Task () ()))
    , update : subaction -> Maybe subfocus -> Maybe subfocus
    , view : Address subaction -> Model -> subfocus -> Html
    , menu : Maybe (Address subaction -> Model -> Maybe subfocus -> Html)
    }

type alias SuperComponent subaction superaction subfocus superfocus =
    { route : List String -> Maybe superaction
    , path : Maybe superfocus -> subfocus -> Maybe PathAction
    , reaction : Address superaction -> subaction -> Maybe superfocus -> Maybe (Task () ())
    , update : subaction -> Maybe superfocus -> Maybe superfocus
    , view : Address superaction -> Model -> subfocus -> Html
    , menu : Address superaction -> Model -> Maybe superfocus -> Maybe Html
    }

type alias MakeComponent subaction superaction subfocus superfocus =
    { prefix : String
    , actionTag : subaction -> superaction
    , focusTag : subfocus -> superfocus
    , reverseFocusTag : superfocus -> Maybe subfocus
    , sub : SubComponent subaction subfocus
    }


superComponent : MakeComponent a b c d -> SuperComponent a b c d
superComponent args =
    let
        route list =
            case list of
                first :: rest ->
                    if first == args.prefix
                        then Maybe.map args.actionTag <| args.sub.route rest
                        else Nothing

                _ ->
                    Nothing
        
        path focus focus' =
            Maybe.map (RouteService.map ((::) args.prefix))
                (args.sub.path (focus `Maybe.andThen` args.reverseFocusTag) focus')

        reaction address action focus =
            args.sub.reaction
                `Maybe.andThen` \reaction ->
                    reaction
                        (forwardTo address args.actionTag) 
                        action
                        (focus `Maybe.andThen` args.reverseFocusTag)

        update action focus =
            Maybe.map args.focusTag <|
                args.sub.update action <|
                    focus `Maybe.andThen` args.reverseFocusTag

        view address model focus =
            args.sub.view (forwardTo address args.actionTag) model focus

        menu address model focus =
            (\menu -> menu (forwardTo address args.actionTag) model (focus `Maybe.andThen` args.reverseFocusTag))
            `Maybe.map` args.sub.menu

    in
        { route = route 
        , path = path
        , reaction = reaction
        , update = update
        , view = view
        , menu = menu
        }



