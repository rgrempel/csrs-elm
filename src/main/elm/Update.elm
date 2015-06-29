module Update where

import Types exposing (Action, Model)
import Focus.Types exposing (DesiredLocation(SetPath, ReplacePath))
import Focus.Model exposing (focus2hash)

update : Action -> Model -> Model
update action model =
    case action of
        Types.NoOp ->
            model

        Types.SwitchLanguage lang ->
            { model | useLanguage <- lang }

        Types.SwitchFocus focus' ->
            { model |
                focus <- focus',
                desiredLocation <- Just <| SetPath ( focus2hash focus' )
            }

        Types.SwitchFocusFromPath focus' ->
            -- If the focus change is coming from the path, then we set up a
            -- possible ReplacePath action, rather than SetPath. That way,
            -- we'll get our canonical path, but we won't update the history,
            -- since clearly the old path got us here too.
            { model |
                focus <- focus',
                desiredLocation <- Just <| ReplacePath ( focus2hash focus' )
            }

        _ -> model
