module Components.Admin.AdminTypes where

import Components.Admin.Audits.AuditsTypes as AuditsTypes

type Focus
    = Metrics 
    | Health
    | Configuration
    | Audits AuditsTypes.Focus
    | Logs
    | ApiDocs
    | Templates
    | Images

type Action
    = FocusMetrics 
    | FocusHealth
    | FocusConfiguration
    | FocusAudits AuditsTypes.Action
    | FocusLogs
    | FocusApiDocs
    | FocusTemplates
    | FocusImages


auditsFocus : Focus -> Maybe AuditsTypes.Focus
auditsFocus focus =
    case focus of
        Audits subfocus -> Just subfocus
        _ -> Nothing
