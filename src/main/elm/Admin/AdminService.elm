module Admin.AdminService where

import Json.Decode as JD exposing ((:=))
import Date exposing (Date)
import Date.TimeStamp exposing (TimeStamp, toDate)
import Dict exposing (Dict)
import Http.Util exposing (send, sendRaw)
import Http exposing (url)
import Task exposing (Task)


type alias AuditEvent =
    { id : Int
    , principal : String
    , timestamp : Date
    , type' : String
    , data : Dict String String 
    }


auditEventDecoder : JD.Decoder AuditEvent
auditEventDecoder =
    JD.object5 AuditEvent
        ( "id" := JD.int )
        ( "principal" := JD.string )
        ( "auditEventDate" := dateDecoder )
        ( "auditEventType" := JD.string )
        ( "data" := JD.dict JD.string )


dateDecoder : JD.Decoder Date
dateDecoder =
    -- This may be slow -- might be better to construct timestamp on server
    JD.tuple7 (\y month d h minute s ms -> toDate (TimeStamp y month d h minute s ms))
        JD.int JD.int JD.int JD.int JD.int JD.int JD.int


allAuditEvents : Task Http.Error (List AuditEvent)
allAuditEvents =
    Http.fromJson (JD.list auditEventDecoder) <|
        sendRaw
            { verb = "GET"
            , headers =
                [ ("Accept", "application/json")
                ]
            , url = url "/api/audits/allNative" []
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
            , url = url "/api/audits/byDatesNative"
                [ ("fromDate", toString from)
                , ("toDate", toString to)
                ]
            , body = Http.empty
            }

