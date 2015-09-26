module Components.Tasks.TasksFocus where

import AppTypes exposing (..)
import RouteHash exposing (HashUpdate)

import Components.Tasks.TasksTypes exposing (..)
import Components.Tasks.TasksText as TasksText

import Html exposing (Html, h1, text, div, li, ul, a, span)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)
import Html.Util exposing (dropdownMenu, dropdownToggle, dropdownPointer, glyphicon, unbreakableSpace)
import Signal exposing (Address, forwardTo)


subcomponent : SubComponent Action Focus 
subcomponent =
    { route = route
    , path = path
    , reaction = Nothing
    , update = update
    , view = view
    , menu = Just menu 
    }


route : List String -> Maybe Action
route list =
    case list of
        first :: rest ->
            case first of
                "process-forms" ->
                    Just FocusProcessForms

                "membership-by-year" ->
                    Just FocusMembershipByYear

                _ ->
                    Nothing

        _ ->
            Nothing


path : Maybe Focus -> Focus -> Maybe HashUpdate
path focus focus' =
    if focus == Just focus'
        then Nothing
        else case focus' of
            ProcessForms ->
                Just <| RouteHash.set ["process-forms"]

            MembershipByYear ->
                Just <| RouteHash.set ["membership-by-year"]


update : Action -> Maybe Focus -> Maybe Focus
update action focus =
    case action of 
        FocusProcessForms ->
            Just ProcessForms

        FocusMembershipByYear ->
            Just MembershipByYear

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
            ProcessForms -> v "Process Forms"
            MembershipByYear -> v "Membership by Year"


-- TODO: ONly show to admins
menu : Address Action -> Model -> Maybe Focus -> Maybe Html
menu address model focus =
    let
        trans =
            TasksText.translate model.language.useLanguage

        standardMenuItem icon message action newFocus =
            li [ classList [ ( "active", focus == Just newFocus ) ] ]
                [ a [ onClick address action ]
                    [ glyphicon icon
                    , text unbreakableSpace
                    , trans message
                    ]
                ]
    
    in
        Just <|
            dropdownPointer [ classList [ ( "active", focus /= Nothing ) ] ]
                [ dropdownToggle []
                    [ glyphicon "tower"
                    , text unbreakableSpace
                    , span [ class "hidden-tablet" ] [ trans TasksText.Title ]
                    , text unbreakableSpace
                    , span [ class "text-bold caret" ] []
                    ]
                , dropdownMenu 
                    [ standardMenuItem "dashboard" TasksText.ProcessForms FocusProcessForms ProcessForms
                    , standardMenuItem "dashboard" TasksText.MembershipByYear FocusMembershipByYear MembershipByYear
                    ]
                ]
