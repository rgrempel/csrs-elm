module Admin.AdminService where

import Json.Decode as JD exposing ((:=))
import Date exposing (Date)
import Dict exposing (Dict)
import Http.Util exposing (send, sendRaw)
import Http exposing (url)
import Task exposing (Task)


type alias AuditEvent =
    { principal : String
    , timestamp : Date
    , type' : String
    , data : Dict String String 
    }


auditEventDecoder : JD.Decoder AuditEvent
auditEventDecoder =
    JD.object4 AuditEvent
        ( "principal" := JD.string )
        ( "timestamp" := dateDecoder )
        ( "type" := JD.string )
        ( "data" := JD.dict JD.string )


dateDecoder : JD.Decoder Date
dateDecoder =
    JD.object1 Date.fromTime JD.float


allAuditEvents : Task Http.Error (List AuditEvent)
allAuditEvents =
    Http.fromJson (JD.list auditEventDecoder) <|
        sendRaw
            { verb = "GET"
            , headers =
                [ ("Accept", "application/json")
                ]
            , url = url "/api/audits/all" []
            , body = Http.empty
            }


auditEventsByDate : Date -> Date -> Task Http.Error (List AuditEvent)
auditEventsByDate from to =
    Http.fromJson (JD.list auditEventDecoder) <|
        sendRaw
            { verb = "GET"
            , headers =
                [ ("Accept", "application/json")
                ]
            , url = url "/api/audits/byDates"
                [ ("fromDate", toString from)
                , ("toDate", toString to)
                ]
            , body = Http.empty
            }

