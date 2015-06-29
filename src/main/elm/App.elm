module App where

import Types exposing (Model, Action(NoOp, SwitchFocusFromPath))
import History exposing (hash, setPath, replacePath)
import Html exposing (Html)
import Model exposing (initialModel)
import Focus.Types exposing (Focus, DesiredLocation(SetPath, ReplacePath))
import Focus.Model exposing (hash2focus, focus2hash)
import Signal exposing (Signal, Mailbox, filter, mailbox, map, filterMap, merge, foldp, dropRepeats)
import Update exposing (update)
import View exposing (view)
import Task exposing (Task, andThen, onError)
import List exposing (foldl)
import Time exposing (delay, inMilliseconds)
import Signal.Extra exposing (foldp')
import TaskTutorial exposing (print)
import Cookies exposing (getCookies)
import Account.Login.Task exposing (attemptLoginTask)
import Http
import Debug


main : Signal Html
main =
    let
        model2html =
            view uiActions.address
    
    in
        map model2html heraclitus


uiActions : Mailbox Action
uiActions =
    mailbox NoOp 


heraclitus : Signal Model
heraclitus =
    let
        initialUpdate = 
            (flip update) initialModel
        
        mergedSignal =
            merge hashSignal uiActions.signal
        
        hashSignal =
            map ( SwitchFocusFromPath << hash2focus ) hash
    
    in
        foldp' update initialUpdate mergedSignal


desiredLocations : Signal (Maybe DesiredLocation)
desiredLocations =
    map ( \m -> m.desiredLocation ) heraclitus


-- Generate a location-changing action if the
-- desired location is different from the current one                                                    
locationAction : Maybe DesiredLocation -> String -> Maybe (Task error ())
locationAction desired current =
    case desired of
        Nothing -> Nothing
        Just (SetPath path) -> if path == current then Nothing else Just <| setPath path
        Just (ReplacePath path) -> if path == current then Nothing else Just <| replacePath path


action2http : Action -> Maybe (Task Http.RawError ())
action2http action =
    case action of
        AttemptLogin credentials ->
            Just <|
                andThen
                    ( attemptLoginTask credentials ) -- RawError Response
                    ( \result -> andThen
                        getCookies 
                        print
                    )
        
        _ -> Nothing


port httpRequests : Signal (Task Http.RawError ())
port httpRequests =
    let default =
        Task.succeed ()
        
    in
        Signal.Extra.filter default (Signal.map action2http uiActions.signal)


port locationUpdates : Signal (Task error ())
port locationUpdates =
    let
        taskMap = 
            Signal.map2 locationAction desiredLocations hash

        default =
            Task.succeed ()

    in
        Signal.Extra.filter default taskMap
    
