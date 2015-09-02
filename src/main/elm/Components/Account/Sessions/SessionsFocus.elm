module Components.Account.Sessions.SessionsFocus where

import AppTypes exposing (..)
import Account.AccountService as AccountService
import Route.RouteService exposing (PathAction(..))

import Components.Account.Sessions.SessionsTypes as SessionsTypes exposing (..)
import Components.Account.Sessions.SessionsText as SessionsText

import Signal exposing (Address, message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit, on, targetValue, onClick)
import Html.Util exposing (role, glyphicon, unbreakableSpace, onlyOnSubmit, showError)
import Maybe exposing (withDefault)
import Task exposing (Task, andThen, onError)
import Task.Util exposing (notify)
import List exposing (all, isEmpty)


subcomponent : SubComponent Action Focus 
subcomponent =
    { route = route
    , path = path
    , reaction = Just reaction
    , update = update
    , view = view
    , menu = Just menuItem 
    }


route : List String -> Maybe Action
route hashList = Just Fetch


path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' =
    if focus == Nothing
        then Just <| SetPath []
        else Nothing


reaction : Address Action -> Action -> Maybe Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        Fetch ->
            Just <|
                AccountService.allSessions
                    `andThen` notify address ShowSessions
                    `onError` notify address ShowError

        DeleteSession session ->
            Just <|
                (AccountService.deleteSession session)
                    `andThen` notify address HandleDeleted
                    `onError` notify address (ShowDeletionError session)

        _ ->
            Nothing


update : Action -> Maybe Focus -> Maybe Focus
update action focus =
    let
        focus' =
            withDefault defaultFocus focus
        
    in
        Just <|
            case action of
                Fetch ->
                    { focus' | status <- Fetching }

                ShowSessions sessions ->
                    { focus'
                        | sessions <- sessions
                        , status <- Showing
                    }

                ShowError error ->
                    { focus' | status <- Error error }

                DeleteSession session ->
                    { focus' | status <- Deleting session }

                HandleDeleted session ->
                    { focus'
                        | status <-
                            Deleted session

                        , sessions <-
                            List.filter
                                (\s -> s.series /= session.series)
                                focus'.sessions
                    }

                ShowDeletionError session error ->
                    { focus' | status <- DeletionError session error }

                _ -> focus'


defaultFocus : Focus
defaultFocus = Focus Start []


view : Address Action -> Model -> Focus -> Html
view address model focus =
    let
        trans =
            SessionsText.translate model.useLanguage

        username =
            withDefault "" <| Maybe.map .username model.currentUser

        result =
            case focus.status of
                Deleted session ->
                    p [ class "alert alert-success" ]
                        [ strong []
                            [ trans SessionsText.Success ]
                        ]

                Error error ->
                    showError model.useLanguage error

                DeletionError session error ->
                    showError model.useLanguage error

                _ ->
                    p [] []

        sessionTable =
            div [ class "table-responsive" ]
                [ table [ class "table table-striped" ]
                    [ thead []
                        [ tr []
                            [ th [] [ trans SessionsText.IPAddress ]
                            , th [] [ trans SessionsText.UserAgent ]
                            , th [] [ trans SessionsText.Date ]
                            , th [] []
                            ]
                        ]
                    , tbody [] 
                        ( List.map makeRow focus.sessions )
                    ]
                ]

        makeRow session =
            tr []
                [ td [] [ text (withDefault "" session.ipAddress) ]
                , td [] [ text (withDefault "" session.userAgent) ]
                , td [] [ text (withDefault "" session.date) ]
                , td []
                    [ button
                        [ type' "submit"
                        , class "btn btn-primary delete-session-button"
                        , onClick address <| DeleteSession session
                        ]
                        [ trans SessionsText.Invalidate ]
                    ]
                ]

    in
        div [ class "csrs-account-sessions container" ]
            [ div [ class "well well-sm" ]
                [ h2 [] [ trans (SessionsText.Title username) ]
                , result
                , sessionTable
                ]
            ]


menuItem : Address Action -> Model -> Maybe Focus -> Maybe Html
menuItem address model focus =
    let
        menu =
            li [ classList [ ( "active", focus /= Nothing ) ] ]
                [ a [ onClick address Fetch ]
                    [ glyphicon "cloud" 
                    , text unbreakableSpace
                    , SessionsText.translate model.useLanguage SessionsText.Sessions
                    ]
                ]

    in
        -- Only show if logged in
        Maybe.map (always menu) model.currentUser
