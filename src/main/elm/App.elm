module App where

import AppTypes exposing (..)
import Account.AccountService as AccountService
import Account.AccountServiceTypes as AccountServiceTypes
import Language.LanguageService as LanguageService
import Language.LanguageTypes as LanguageTypes
import RouteHash exposing (HashUpdate)

import Components.FocusTypes as FocusTypes
import Components.FocusUI as FocusUI

import Html exposing (Html, div)
import Signal exposing (Signal, Mailbox, filter, mailbox, filterMap, merge, foldp, dropRepeats, sampleOn)
import Signal.Extra exposing (foldp', passiveMap2)
import Task exposing (Task, andThen, onError)
import Task.Util exposing (batch)


{- Collect the wiring for submodules -}

accountModule =
    superModule
        { modelTag = .account
        , modelUpdater = \a b -> {b | account <- a}
        , actionTag = AccountAction
        , submodule = AccountService.submodule
        }

focusModule =
    superModule
        { modelTag = .focus
        , modelUpdater = \a b -> {b | focus <- a}
        , actionTag = FocusAction
        , submodule = FocusUI.submodule
        }

languageModule =
    superModule
        { modelTag = .language
        , modelUpdater = \a b -> {b | language <- a}
        , actionTag = LanguageAction
        , submodule = LanguageService.submodule
        }


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
            accountModule.update subaction model

        FocusAction subaction ->
            focusModule.update subaction model

        LanguageAction subaction ->
            languageModule.update subaction model

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
-}
initialTask : Task () () 
initialTask =
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


port routeTasks : Signal (Task () ())
port routeTasks =
    RouteHash.start
        { prefix = RouteHash.defaultPrefix
        , models = models
        , delta2update = FocusUI.delta2path
        , address = FocusTypes.address
        , location2action = FocusUI.route
        }
