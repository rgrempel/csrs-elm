module Tasks.TasksFocus where

import Tasks.TasksTypes exposing (..)

import Html exposing (Html, h1, text, div, li, ul, a, span)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)
import Signal exposing (Address, forwardTo)
import Tasks.TasksText as TasksText
import Language.LanguageService exposing (Language)
import Html.Util exposing (dropdownMenu, dropdownToggle, dropdownPointer, glyphicon, unbreakableSpace)


hash2focus : List String -> Maybe Focus
hash2focus hashList =
    case hashList of
        first :: rest ->
            case first of
                "process-forms" ->
                    Just ProcessForms

                "membership-by-year" ->
                    Just MembershipByYear

                _ ->
                    Nothing

        _ ->
            Nothing


focus2hash : Focus -> List String
focus2hash focus =
    case focus of
        ProcessForms ->
            ["process-forms"]

        MembershipByYear ->
            ["membership-by-year"]


updateFocus : Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    case (action, focus) of 
        (FocusProcessForms, _) ->
            Just ProcessForms

        (FocusMembershipByYear, _) ->
            Just MembershipByYear

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
            ProcessForms -> v "Process Forms"
            MembershipByYear -> v "Membership by Year"


-- TODO: ONly show to admins
renderMenu : Address Action -> Maybe Focus -> Language -> Html
renderMenu address focus language =
    let
        trans =
            TasksText.translate language

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
                , span [ class "hidden-tablet" ] [ trans TasksText.Title ]
                , text unbreakableSpace
                , span [ class "text-bold caret" ] []
                ]
            , dropdownMenu 
                [ standardMenuItem "dashboard" TasksText.ProcessForms FocusProcessForms ProcessForms
                , standardMenuItem "dashboard" TasksText.MembershipByYear FocusMembershipByYear MembershipByYear
                ]
            ]


