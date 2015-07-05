module App where

import History exposing (hash, setPath, replacePath)
import Html exposing (Html, div)
import Signal exposing (Signal, Mailbox, filter, mailbox, filterMap, merge, foldp, dropRepeats)
import Task exposing (Task, andThen, onError)
import List exposing (foldl)
import Focus.FocusUI as FocusUI exposing (DesiredLocation(SetPath, ReplacePath))
import NavBar.NavBarUI as NavBarUI
import Account.AccountService as AccountService
import Language.LanguageService as LanguageService
import Signal.Extra exposing (foldp')
import TaskTutorial exposing (print)
import Http exposing (RawError, Response)

type alias Model =
    LanguageService.Model (
    FocusUI.Model (
      {} 
    ))


initialModel : Model
initialModel =
    LanguageService.init (
    FocusUI.init (
        {}
    ))


type Action
    = AccountAction AccountService.Action
    | FocusAction FocusUI.Action
    | LanguageAction LanguageService.Action
    | NoOp


service : Signal Action
service =
    Signal.mergeMany
        [ Signal.map FocusAction <| FocusUI.hashSignal
        , Signal.map FocusAction <| .signal FocusUI.focusActions
        , Signal.map AccountAction <| .signal AccountService.service
        , Signal.map LanguageAction <| .signal LanguageService.service
        ]


main : Signal Html
main =
    Signal.map render heraclitus


render : Model -> Html
render model =
    div []
    [ NavBarUI.render model.focus model.useLanguage
    , FocusUI.render model model.useLanguage
    ]


heraclitus : Signal Model
heraclitus =
    let
        initialUpdate = 
            (flip update) initialModel 
        
    in
        foldp' update initialUpdate service


desiredLocations : Signal (Maybe DesiredLocation)
desiredLocations =
    Signal.map .desiredLocation heraclitus


-- Generate a location-changing action if the
-- desired location is different from the current one                                                    
locationAction : Maybe DesiredLocation -> String -> Maybe (Task error ())
locationAction desired current =
    case desired of
        Nothing -> Nothing
        Just (SetPath path) -> if path == current then Nothing else Just <| setPath path
        Just (ReplacePath path) -> if path == current then Nothing else Just <| replacePath path


port locationUpdates : Signal (Task error ())
port locationUpdates =
    let
        taskMap = 
            Signal.map2 locationAction desiredLocations hash

        default =
            Task.succeed ()

    in
        Signal.Extra.filter default taskMap
    

port tasks : Signal (Task () ())
port tasks =
    Signal.Extra.filter
        (Task.succeed ()) 
        (Signal.map AccountService.action2task (.signal AccountService.service))


update : Action -> Model -> Model
update action model =
    case action of
        -- Doesn't exist at moment ...
        -- AccountAction accountAction ->
        --     AccountService.update accountAction model'

        FocusAction focusAction ->
            FocusUI.update focusAction model
        
        LanguageAction languageAction ->
            LanguageService.update languageAction model

        _ -> model



