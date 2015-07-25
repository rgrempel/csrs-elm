module Components.FocusTypes where

import Components.Home.HomeTypes as HomeTypes
import Components.Account.AccountTypes as AccountTypes
import Components.Admin.AdminTypes as AdminTypes
import Components.Tasks.TasksTypes as TasksTypes
import Components.Error.ErrorTypes as ErrorTypes

import Task exposing (Task)
import Signal exposing (Mailbox, Address, mailbox, send)


type Focus
    = Home HomeTypes.Focus
    | Account AccountTypes.Focus
    | Admin AdminTypes.Focus
    | Tasks TasksTypes.Focus
    | Error ErrorTypes.Focus 

type Action
    = Route (List String)
    | FocusAccount AccountTypes.Action
    | FocusHome HomeTypes.Action
    | FocusAdmin AdminTypes.Action
    | FocusTasks TasksTypes.Action
    | FocusError ErrorTypes.Action
    | NoOp


type alias FocusModel m =
    { m | focus : Focus }


actions : Mailbox Action
actions = mailbox NoOp


address : Address Action
address = actions.address


do : Action -> Task x ()
do = send address


{-| Possibly specialize the focus to the HomeTypes.Focus, if that is
what it was constructed from.

Now, I would really like to generalize this function ... essentially,
I'd like to implement a function which would have a signature sort of
like this:

```elm
specialize : (a -> b) -> b -> Maybe a
```

The logic of it would be: if the second parameter was constructed with the
first parameter, then deconstruct it ... otherwise return nothing.

This is, of course, trivial to do with a case statement, but the case statement
requires that the (a -> b) parameter be listed *statically* -- it can't be
supplied as a parameter.

I suspect that the method I want could be implemented in a Native module,
relying on compiler internals (that is, relying on things in the generated code
that aren't exposed normally). However, it would be limited to cases in which
the first parameter actually is a constructor, rather than just some function
that happens to take an a and return a b. (That is, we would always return
Nothing in the latter case, since we wouldn't know).
-}
homeFocus : Focus -> Maybe HomeTypes.Focus
homeFocus focus =
    case focus of
        Home subfocus -> Just subfocus
        _ -> Nothing


accountFocus : Focus -> Maybe AccountTypes.Focus
accountFocus focus =
    case focus of
        Account subfocus -> Just subfocus
        _ -> Nothing


adminFocus : Focus -> Maybe AdminTypes.Focus
adminFocus focus =
    case focus of
        Admin subfocus -> Just subfocus
        _ -> Nothing


tasksFocus : Focus -> Maybe TasksTypes.Focus
tasksFocus focus =
    case focus of
        Tasks subfocus -> Just subfocus
        _ -> Nothing


errorFocus : Focus -> Maybe ErrorTypes.Focus
errorFocus focus =
    case focus of
        Error subfocus -> Just subfocus
        _ -> Nothing
