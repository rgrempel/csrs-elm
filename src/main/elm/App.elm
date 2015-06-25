module App where

import Action exposing (Action(SwitchFocusFromPath, NoOp))
import History exposing (hash, setPath, replacePath)
import Html exposing (Html)
import Model exposing (Model, initialModel)
import Model.Focus as MF exposing (Focus, UpdateLocation, hash2focus, focus2hash)
import Signal exposing (Signal, Mailbox, mailbox, map, filterMap, merge, foldp, dropRepeats)
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


port hashUpdates : Signal (Task error ())
port hashUpdates =
    let
        change2task (focus, updateLocation) =
            case updateLocation of
                MF.Ignore -> Task.succeed () 
                MF.Set -> setPath <| focus2hash focus 
                MF.Replace -> replacePath <| focus2hash focus

        focusChanges =
            dropRepeats <| map (\m -> (,) m.focus m.updateLocation) heraclitus  
    
    in

        map change2task focusChanges
