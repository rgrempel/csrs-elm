module Task.Util where

import Signal exposing (Address)
import Task exposing (Task)


{-| A convenience for a common pattern, where we want to take the result of
a task and then send it to an address with a tag. For example, if you had
the following types:

    type Action
        = HandleResult Int
        | HandleError String

    mailbox : Mailbox Action
    task : Task Int String

... then you might use `notify` in this way:

    task
        `andThen` notify mailbox.address HandleResult
        `onError` notify mailbox.address HandleError

Of course, the (result -> action) function need not actually be a tag ... it
could be any function that fits the signature.
-}
notify : Address action -> (result -> action) -> result -> Task x ()
notify address tag result =
    Signal.send address (tag result)


{-| Given a list of tasks, produce a task which executes each task in parallel,
ignoring the results.
-}
batch : List (Task.Task x a) -> Task () ()
batch =
    Task.map (always ()) <<
        Task.sequence <<
            List.map Task.spawn

