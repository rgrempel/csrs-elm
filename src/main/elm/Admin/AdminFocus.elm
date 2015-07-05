module Admin.AdminFocus where

import Html exposing (Html, h1, text, div, li, ul, a, span)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)
import Signal exposing (Address, forwardTo)
import Admin.AdminText as AdminText
import Language.LanguageService exposing (Language)
import Html.Util exposing (dropdownMenu, dropdownToggle, dropdownPointer, glyphicon, unbreakableSpace)

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


hash2focus : List String -> Maybe Focus
hash2focus hashList =
    case hashList of
        first :: rest ->
            case first of
                "metrics" ->
                    Just Metrics

                "health" ->
                    Just Health

                "configuration" ->
                    Just Configuration

                "audits" ->
                    Just Audits

                "logs" ->
                    Just Logs

                "api" ->
                    Just ApiDocs

                "templates" ->
                    Just Templates

                "images" ->
                    Just Images

                _ ->
                    Nothing

        _ ->
            Nothing


focus2hash : Focus -> List String
focus2hash focus =
    case focus of
        Metrics ->
            ["metrics"]

        Health ->
            ["health"]

        Configuration ->
            ["configuration"]

        Audits ->
            ["audits"]

        Logs ->
            ["logs"]

        ApiDocs ->
            ["api"]

        Templates ->
            ["templates"]

        Images ->
            ["images"]


updateFocus : Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    case (action, focus) of
        
        (FocusMetrics, _) ->
            Just Metrics

        (FocusHealth, _) ->
            Just Health

        (FocusConfiguration, _) ->
            Just Configuration

        (FocusAudits, _) ->
            Just Audits

        (FocusApiDocs, _) ->
            Just ApiDocs

        (FocusTemplates, _) ->
            Just Templates
        
        (FocusImages, _) ->
            Just Images
        
        _ ->
            Nothing


renderFocus : Address Action -> Focus -> Language -> Html
renderFocus address focus language =
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
            ApiDocs -> v "API Docs"
            Templates -> v "Templates"
            Images -> v "Images"


-- TODO: ONly show to admins
renderMenu : Address Action -> Maybe Focus -> Language -> Html
renderMenu address focus language =
    let
        trans =
            AdminText.translate language

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


