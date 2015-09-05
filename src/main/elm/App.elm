module App where

import AppTypes exposing (..)
import Account.AccountService as AccountService
import Account.AccountServiceTypes as AccountServiceTypes
import Language.LanguageService as LanguageService
import Language.LanguageTypes as LanguageTypes
import Route.RouteService as RouteService exposing (PathAction(..))

import Components.FocusTypes as FocusTypes
import Components.FocusUI as FocusUI

import Html exposing (Html, div)
import Signal exposing (Signal, Mailbox, filter, mailbox, filterMap, merge, foldp, dropRepeats, sampleOn)
import Signal.Extra exposing (foldp', passiveMap2)
import Task exposing (Task, andThen, onError)
import Task.Util exposing (batch)


{- Collect the wiring for submodules -}

accountModule = superModule .account AccountAction AccountService.submodule
focusModule = superModule .focus FocusAction FocusUI.submodule
languageModule = superModule .language LanguageAction LanguageService.submodule


{-| The initial model.

We collect the initialization of the model from the various modules that 'own'
the parts of the model.
-}
initialModel : Model
initialModel =
    { language = languageModule.initialModel
    , account = accountModule.initialModel
    , focus = focusModule.initialModel
    }


{-| The actions our app can perform

We don't have any top-level actions ... we simply dispatch to one
module or another.
-}
type Action
    = AccountAction AccountServiceTypes.Action
    | FocusAction FocusTypes.Action
    | LanguageAction LanguageTypes.Action
    | NoOp


{-| The merger of all the action signals defined by various modules. -}
actions : Signal Action
actions =
    Signal.mergeMany
        [ .actions focusModule
        , .actions accountModule
        , .actions languageModule
        ]


{-| The update function.

Just dispatch to the various models that can handle actions.
-}
update : Action -> Model -> Model
update action model =
    case action of
        AccountAction subaction ->
            { model | account <- accountModule.update subaction model }

        FocusAction subaction ->
            { model | focus <- focusModule.update subaction model }

        LanguageAction subaction ->
            { model | language <- languageModule.update subaction model }

        _ ->
            model


{-| Like update, except returns an additional task to perform in response to
the action (rather than an updated model).

Of coure, the task returned may be a sequence, or composed with various
`andThen` tasks.

An alternative is to let have the `update` function return a tuple of model and
task. However, I think it's nice to keep the two things separate.

Originally, I didn't provide access to the model here -- all the needed
information had to be in the action itself. However, this turned out to be too
limiting for some cases, so now I provide it. Of course, the access to the
model is essentially read-only. However, if the reaction needs to change the
model, then it can simply include a Task that sends the appropriate message.
-}
reaction : Action -> Model -> Maybe (Task () ())
reaction action model =
    model |>
        case action of
            FocusAction subaction ->
                .reaction focusModule subaction

            AccountAction subaction ->
                .reaction accountModule subaction

            LanguageAction subaction ->
                .reaction languageModule subaction

            _ ->
                always Nothing 


{-| A task to perform when the app starts.

Note that we've defined this as a sequence, even though it's just
one task so far, since one could easily want more tasks at some point.
-}
initialTask : Task () () 
initialTask =
    let
        apply wiring =
            wiring.sub.initialTask

    in
        batch <|
            List.filterMap identity
                [ .initialTask accountModule
                , .initialTask focusModule
                , .initialTask languageModule
                ]


{-| Actually executes the reaction tasks.

Note the default is the initialTask, so that the initialTask gets executed.
-}
port reactions : Signal (Task () ())
port reactions =
    Signal.Extra.filter
        initialTask
        (Signal.map2 reaction actions models)


{-| A signal of the changing model over time.

Note that we use foldp' from Signal.Extra to work around a characteristic
of the standard foldp. That characteristic is that the standard foldp
does nothing with the initial value of the Signal that you supply to it.
This was causing problems at one point.
-}
models : Signal Model
models =
    let
        initialUpdate = (flip update) initialModel 
        
    in
        foldp' update initialUpdate actions 


{-| Turns our model into Html. -}
view : Model -> Html
view = FocusUI.view


{-| The main method, which generates a signal of Html to display. -}
main : Signal Html
main = Signal.map view models 


{-| A signal of changes to the model.

The tuple has the previous model first and then the current model.

We use this to calculate possible changes to the location. We need the previous
model because whether to make the change, and whether to make it a "setPath" or
"replacePath", depends on the previous state.  Well, I suppose it could depend
on the previous location, but this seems simpler ... we just assume that the
previous location was propertly set (which seems safe, since this is what is
doing it ...).
-}
deltas : Signal (Model, Model)
deltas =
    let
        update model delta = (snd delta, model)

    in
        Signal.foldp update (initialModel, initialModel) models


paths : Signal (Maybe PathAction)
paths =
    passiveMap2 FocusUI.delta2path deltas RouteService.routes


port pathTasks : Signal (Task () ())
port pathTasks =
    Signal.Extra.filter
        (Task.succeed ())
        (Signal.map (Maybe.map RouteService.do) paths)


route : List String -> Maybe PathAction -> Maybe (Task () ())
route list action =
    Maybe.map
        FocusTypes.do
        (case action of
            Just (SetPath current) ->
                if current == list
                    then Nothing
                    else FocusUI.route list

            Just (ReplacePath current) ->
                if current == list
                    then Nothing
                    else FocusUI.route list

            Nothing ->
                FocusUI.route list
        )


port routes : Signal (Task () ())
port routes =
    Signal.Extra.filter
        (Task.succeed ())
        (passiveMap2 route RouteService.routes paths)
