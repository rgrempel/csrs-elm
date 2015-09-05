module Components.Admin.AdminFocus where

import AppTypes exposing (..)
import Route.RouteService exposing (PathAction(..))
import Account.AccountServiceTypes exposing (hasRole, Role(..))

import Components.Admin.AdminText as AdminText
import Components.Admin.AdminTypes exposing (..)
import Components.Admin.Audits.AuditsFocus as AuditsFocus

import Html exposing (Html, h1, text, div, li, ul, a, span)
import Html.Attributes exposing (class, classList, href, id)
import Html.Events exposing (onClick)
import Signal exposing (Address, forwardTo)
import Html.Util exposing (dropdownMenu, dropdownToggle, dropdownPointer, glyphicon, unbreakableSpace)
import Task exposing (Task)


subcomponent : SubComponent Action Focus 
subcomponent =
    { route = route
    , path = path
    , reaction = Just reaction 
    , update = update
    , view = view
    , menu = Just menu 
    }

audits =
    superComponent <|
        MakeComponent "audits" FocusAudits Audits auditsFocus AuditsFocus.subcomponent


route : List String -> Maybe Action
route list =
    Maybe.oneOf
        [ audits.route list
        ]


path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' =
    case focus' of
        Metrics ->
            Just <| SetPath ["metrics"]

        Health ->
            Just <| SetPath ["health"]

        Configuration ->
            Just <| SetPath ["configuration"]

        Audits subfocus ->
            audits.path focus subfocus

        Logs ->
            Just <| SetPath ["logs"]

        ApiDocs ->
            Just <| SetPath ["api"]

        Templates ->
            Just <| SetPath ["templates"]

        Images ->
            Just <| SetPath ["images"]

        _ ->
            Nothing


reaction : Address Action -> Action -> Maybe Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        FocusAudits subaction ->
            audits.reaction address subaction focus

        _ ->
            Nothing


update : Action -> Maybe Focus -> Maybe Focus
update action focus =
    case action of
        FocusMetrics ->
            Just Metrics

        FocusHealth ->
            Just Health

        FocusConfiguration ->
            Just Configuration

        FocusAudits subaction ->
            audits.update subaction focus

        FocusLogs ->
            Just Logs

        FocusApiDocs ->
            Just ApiDocs

        FocusTemplates ->
            Just Templates
        
        FocusImages ->
            Just Images
        
        _ ->
            Nothing


view : Address Action -> Model -> Focus -> Html
view address model focus =
    case focus of
        Audits subfocus ->
            audits.view address model subfocus

        _ ->
            div [] []


menu : Address Action -> Model -> Maybe Focus -> Maybe Html
menu address model focus =
    let
        trans =
            AdminText.translate model.language.useLanguage

        user =
            model.account.currentUser

        standardMenuItem icon message action newFocus =
            Just <|
                li [ classList [ ( "active", focus == Just newFocus ) ] ]
                    [ a [ onClick address action ]
                        [ glyphicon icon
                        , text unbreakableSpace
                        , trans message
                        ]
                    ]
   
        menu =
            dropdownPointer
                [ classList [ ( "active", focus /= Nothing ) ]
                , id "navbar-admin-menu"
                ]
                [ dropdownToggle []
                    [ glyphicon "tower"
                    , text unbreakableSpace
                    , span [ class "hidden-tablet" ] [ trans AdminText.Title ]
                    , text unbreakableSpace
                    , span [ class "text-bold caret" ] []
                    ]
                , dropdownMenu <|
                    List.filterMap identity <|
                        [ audits.menu address model focus
                        ]
                        ++
                        [ standardMenuItem "dashboard" AdminText.Metrics FocusMetrics Metrics
                        , standardMenuItem "heart" AdminText.Health FocusHealth Health
                        , standardMenuItem "list-alt" AdminText.Configuration FocusConfiguration Configuration
                        , standardMenuItem "tasks" AdminText.Logs FocusLogs Logs
                        , standardMenuItem "book" AdminText.ApiDocs FocusApiDocs ApiDocs
                        , standardMenuItem "blackboard" AdminText.Templates FocusTemplates Templates
                        , standardMenuItem "picture" AdminText.Images FocusImages Images
                        ]
                ]

    in
        user
            `Maybe.andThen` hasRole RoleAdmin
                `Maybe.andThen` \isAdmin ->
                    if isAdmin then Just menu else Nothing

