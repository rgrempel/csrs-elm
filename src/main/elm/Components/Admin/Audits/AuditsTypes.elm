module Components.Admin.Audits.AuditsTypes where

import Admin.AdminService exposing (AuditEvent)
import Http

type Action
    = FetchAll
    | ShowEvents (List AuditEvent)
    | ShowError Http.Error
    | ClickedHeader Header

type Status
    = Start
    | Fetching
    | Showing
    | Error Http.Error

type alias Focus =
    { status: Status
    , events: List AuditEvent
    , sortBy: Header
    , sortReversed: Bool
    }

type Header
    = Timestamp
    | Principal
    | Type


defaultFocus : Focus
defaultFocus = Focus Start [] Timestamp True
