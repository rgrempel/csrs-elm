module Update where

import Action
import Model exposing (Model)
import Model.Focus as MF

update : Action.Action -> Model -> Model
update action model =
    case action of
        Action.NoOp ->
            model

        Action.SwitchLanguage lang ->
            { model | useLanguage <- lang }

        Action.SwitchFocus focus' ->
            { model |
                focus <- focus',
                desiredLocation <- Just <| MF.SetPath ( MF.focus2hash focus' )
            }

        Action.SwitchFocusFromPath focus' ->
            -- If the focus change is coming from the path, then we set up a
            -- possible ReplacePath action, rather than SetPath. That way,
            -- we'll get our canonical path, but we won't update the history,
            -- since clearly the old path got us here too.
            { model |
                focus <- focus',
                desiredLocation <- Just <| MF.ReplacePath ( MF.focus2hash focus' )
            }

        _ -> model
