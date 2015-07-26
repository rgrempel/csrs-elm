module Components.Admin.AdminFocus where

import AppTypes exposing (..)
import Route.RouteService exposing (PathAction(..))

import Components.Admin.AdminText as AdminText
import Components.Admin.AdminTypes exposing (..)

import Html exposing (Html, h1, text, div, li, ul, a, span)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)
import Signal exposing (Address, forwardTo)
import Html.Util exposing (dropdownMenu, dropdownToggle, dropdownPointer, glyphicon, unbreakableSpace)


route : List String -> Maybe Action
route hashList =
    case hashList of
        first :: rest ->
            case first of
                "metrics" ->
                    Just FocusMetrics

                "health" ->
                    Just FocusHealth

                "configuration" ->
                    Just FocusConfiguration

                "audits" ->
                    Just FocusAudits

                "logs" ->
                    Just FocusLogs

                "api" ->
                    Just FocusApiDocs

                "templates" ->
                    Just FocusTemplates

                "images" ->
                    Just FocusImages

                _ ->
                    Nothing

        _ ->
            Nothing


path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' =
    if (focus == Just focus')
        then Nothing
        else case focus' of
            Metrics ->
                Just <| SetPath ["metrics"]

            Health ->
                Just <| SetPath ["health"]

            Configuration ->
                Just <| SetPath ["configuration"]

            Audits ->
                Just <| SetPath ["audits"]

            Logs ->
                Just <| SetPath ["logs"]

            ApiDocs ->
                Just <| SetPath ["api"]

            Templates ->
                Just <| SetPath ["templates"]

            Images ->
                Just <| SetPath ["images"]


update : Action -> Maybe Focus -> Maybe Focus
update action focus =
    case action of
        FocusMetrics ->
            Just Metrics

        FocusHealth ->
            Just Health

        FocusConfiguration ->
            Just Configuration

        FocusAudits ->
            Just Audits

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
    let 
        v s =
            div [ class "container" ]
                [ h1 [] [ text s ]
                ]

    in
        case focus of
            Metrics -> v "Metrics"
            Health -> v "Health"
            Configuration -> v "Configuration"
            Audits -> v "Audits"
            Logs -> v "Logs"
            ApiDocs -> v "API Docs"
            Templates -> v "Templates"
            Images -> v "Images"


-- TODO: ONly show to admins
menu : Address Action -> Model -> Maybe Focus -> Html
menu address model focus =
    let
        trans =
            AdminText.translate model.useLanguage

        standardMenuItem icon message action newFocus =
            li [ classList [ ( "active", focus == Just newFocus ) ] ]
                [ a [ onClick address action ]
                    [ glyphicon icon
                    , text unbreakableSpace
                    , trans message
                    ]
                ]
    
    in
        dropdownPointer [ classList [ ( "active", focus /= Nothing ) ] ]
            [ dropdownToggle
                [ glyphicon "tower"
                , text unbreakableSpace
                , span [ class "hidden-tablet" ] [ trans AdminText.Title ]
                , text unbreakableSpace
                , span [ class "text-bold caret" ] []
                ]
            , dropdownMenu 
                [ standardMenuItem "dashboard" AdminText.Metrics FocusMetrics Metrics
                , standardMenuItem "heart" AdminText.Health FocusHealth Health
                , standardMenuItem "list-alt" AdminText.Configuration FocusConfiguration Configuration
                , standardMenuItem "bell" AdminText.Audits FocusAudits Audits
                , standardMenuItem "tasks" AdminText.Logs FocusLogs Logs
                , standardMenuItem "book" AdminText.ApiDocs FocusApiDocs ApiDocs
                , standardMenuItem "blackboard" AdminText.Templates FocusTemplates Templates
                , standardMenuItem "picture" AdminText.Images FocusImages Images
                ]
            ]
