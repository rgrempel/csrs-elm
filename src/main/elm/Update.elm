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
                updateLocation <- MF.Set 
            }

        Action.SwitchFocusFromPath focus' ->
            { model |
                focus <- focus',
                updateLocation <- MF.Ignore
            }

        _ -> model
