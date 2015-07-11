module Focus.FocusTypes where

import Home.HomeTypes as HomeTypes
import Account.AccountTypes as AccountTypes
import Admin.AdminTypes as AdminTypes
import Tasks.TasksTypes as TasksTypes
import Task exposing (Task)
import Signal exposing (Mailbox, Address, mailbox, send)

type Focus
    = Home HomeTypes.Focus
    | Account AccountTypes.Focus
    | Admin AdminTypes.Focus
    | Tasks TasksTypes.Focus
    | Error 

type Action
    = SwitchFocus Focus
    | SwitchFocusFromPath Focus
    | FocusAccount AccountTypes.Action
    | FocusHome HomeTypes.Action
    | FocusAdmin AdminTypes.Action
    | FocusTasks TasksTypes.Action
    | NoOp


actions : Mailbox Action
actions = mailbox NoOp


address : Address Action
address = actions.address


do : Action -> Task x ()
do = send address
