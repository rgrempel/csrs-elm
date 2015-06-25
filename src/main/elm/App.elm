module App where

import Action exposing (Action(NoOp, SwitchFocusFromPath))
import History exposing (hash, setPath, replacePath)
import Html exposing (Html)
import Model exposing (Model, initialModel)
import Model.Focus as MF exposing (Focus, DesiredLocation, hash2focus, focus2hash)
import Signal exposing (Signal, Mailbox, filter, mailbox, map, filterMap, merge, foldp, dropRepeats)
import Update exposing (update)
import View exposing (view)
import Task exposing (Task)
import Time exposing (delay, inMilliseconds)
import Signal.Extra exposing (foldp')


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
        Just (MF.SetPath path) -> if path == current then Nothing else Just <| setPath path
        Just (MF.ReplacePath path) -> if path == current then Nothing else Just <| replacePath path


port locationUpdates : Signal (Task error ())
port locationUpdates =
    let
        taskMap = 
            Signal.map2 locationAction desiredLocations hash

        default =
            Task.succeed ()

    in
        Signal.Extra.filter default taskMap
    
