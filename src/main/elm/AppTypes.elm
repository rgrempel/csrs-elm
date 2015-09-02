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


{-| A record which represents the functions present in the subComponent which
participate in the standard wiring between subComponents and superComponents.
Note that it should be possible to define the whole record from the subComponent's
point of view, so it should always be possible to do this inside the subComponent's
module. (Of course, the functions referred to here don't actually have to be defined
in a single Elm module, but that will be a typical pattern.
-}
type alias SubComponent subaction subfocus =
    { route : List String -> Maybe subaction
    , path : Maybe subfocus -> subfocus -> Maybe PathAction
    , reaction : Maybe (Address subaction -> subaction -> Maybe subfocus -> Maybe (Task () ()))
    , update : subaction -> Maybe subfocus -> Maybe subfocus
    , view : Address subaction -> Model -> subfocus -> Html

    {- The menu property is wrapped in a Maybe so that you can specify that
    there is no menu function at all. It returns a Maybe Html so that you can
    decide at runtime not to show the menu. The subfocus is Maybe because we
    typcially show all the menus -- that is, even for virtual pages that don't
    have the focus.  The state of the menu might depend on whether the submodule
    has the focus, for instance, the 'active' class might be applied.
    -}
    , menu : Maybe (Address subaction -> Model -> Maybe subfocus -> Maybe Html)
    }


{-| This record represents some SubComponent after it has been 'wired' to a
specific SuperComponent. So perhaps the naming is a bit off -- this isn't the
SuperComponent itself, but the SubComponent as combined with a specific
SuperComponent. So, it represents the functions that the SuperComponent would
actually call in order to call the SubComponent's functions. And, of course,
the point of the indirection is to get the standard 'sugar' that is provided
below by the superComponent method.

TODO: Rethink the naming here.
-}
type alias SuperComponent subaction superaction subfocus superfocus =
    { route : List String -> Maybe superaction
    , path : Maybe superfocus -> subfocus -> Maybe PathAction
    , reaction : Address superaction -> subaction -> Maybe superfocus -> Maybe (Task () ())
    , update : subaction -> Maybe superfocus -> Maybe superfocus
    , view : Address superaction -> Model -> subfocus -> Html
    , menu : Address superaction -> Model -> Maybe superfocus -> Maybe Html
    }


{-| This record represents the arguments to the superComponent function.
Its purpose is simply to avoid a five-argument function. Essentially,
the properties of this record are the various things we need to know in
order to dispatch from the superComponent to the subComponent.
-}
type alias MakeComponent subaction superaction subfocus superfocus =
    { prefix : String
    , actionTag : subaction -> superaction
    , focusTag : subfocus -> superfocus
    , reverseFocusTag : superfocus -> Maybe subfocus
    , sub : SubComponent subaction subfocus
    }


{-| This is the function that actually wires together the subComponent and
the superComponent. Essentially, it adapts between two things:

* The way it is most convenient to call the functions from the superComponent; and
* The way it is most convenient to define the functions in the subComponent.

That way, both the call-site and the called function can be kept simpler than
they would otherwise be -- the complexity is handled here, once and for all.
-}
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
            args.sub.menu `Maybe.andThen` \menu ->
                menu 
                    (forwardTo address args.actionTag)
                    model
                    (focus `Maybe.andThen` args.reverseFocusTag)

    in
        { route = route 
        , path = path
        , reaction = reaction
        , update = update
        , view = view
        , menu = menu
        }



