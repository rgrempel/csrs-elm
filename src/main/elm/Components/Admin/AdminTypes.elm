module Components.Admin.AdminTypes where

type Focus
    = Metrics 
    | Health
    | Configuration
    | Audits
    | Logs
    | ApiDocs
    | Templates
    | Images

type Action
    = FocusMetrics 
    | FocusHealth
    | FocusConfiguration
    | FocusAudits
    | FocusLogs
    | FocusApiDocs
    | FocusTemplates
    | FocusImages


