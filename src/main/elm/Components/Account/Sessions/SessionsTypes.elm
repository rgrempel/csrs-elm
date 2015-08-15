module Components.Account.Sessions.SessionsTypes where

import Account.AccountServiceTypes exposing (Session)
import Http

-- In principle, a session should be handled in a submodule.
-- However, what you can do with a session is so simple
-- (just delete it), that I think I'll just do it all in the
-- one module.
type Action
    = Fetch
    | ShowSessions (List Session)
    | ShowError Http.Error
    | DeleteSession Session 
    | HandleDeleted Session
    | ShowDeletionError Session Http.Error

type Status
    = Start
    | Fetching
    | Showing
    | Deleting Session
    | Deleted Session
    | Error Http.Error
    | DeletionError Session Http.Error

type alias Focus =
    { status : Status
    , sessions : List Session
    }

