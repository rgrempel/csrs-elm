module Components.Admin.Audits.AuditsFocus where

import AppTypes exposing (..)
import Route.RouteService exposing (PathAction(..))
import Admin.AdminService exposing (AuditEvent, allAuditEvents)

import Components.Admin.Audits.AuditsTypes as AuditsTypes exposing (..)
import Components.Admin.Audits.AuditsText as AuditsText

import Signal exposing (message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace, showError, onlyOnSubmit)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task)
import Task.Util exposing (..)
import List exposing (all, isEmpty)
import Dict


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
route hashList = Just FetchAll 


path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' =
    if focus == Nothing
        then Just <| SetPath []
        else Nothing


-- Should move this one up
dispatch : Task x a -> Address action -> (x -> action) -> (a -> action) -> Task () ()
dispatch task address errorTag successTag =
    task
        `Task.andThen` (Signal.send address << successTag)
        `Task.onError` (Signal.send address << errorTag)


reaction : Address Action -> Action -> Maybe Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        FetchAll ->
            Just <|
                dispatch allAuditEvents address ShowError ShowEvents
                    
        _ ->
            Nothing

{-
        $scope.onChangeDate = function () {
            var dateFormat = 'yyyy-MM-dd';
            var fromDate = $filter('date')($scope.fromDate, dateFormat);
            var toDate = $filter('date')($scope.toDate, dateFormat);

            AuditsService.findByDates(fromDate, toDate).then(function (data) {
                $scope.audits = data;
            });
        };

        // Date picker configuration
        $scope.today = function () {
            // Today + 1 day - needed if the current day must be included
            var today = new Date();
            $scope.toDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);
        };

        $scope.previousMonth = function () {
            var fromDate = new Date();
            if (fromDate.getMonth() === 0) {
                fromDate = new Date(fromDate.getFullYear() - 1, 0, fromDate.getDate());
            } else {
                fromDate = new Date(fromDate.getFullYear(), fromDate.getMonth() - 1, fromDate.getDate());
            }

            $scope.fromDate = fromDate;
        };

        $scope.today();
        $scope.previousMonth();
        $scope.onChangeDate();
    });
-}


update : Action -> Maybe Focus -> Maybe Focus
update action focus =
    let
        focus' =
            withDefault defaultFocus focus
        
    in
        Just <|
            case action of
                FetchAll ->
                    { focus' | status <- Fetching }

                ShowEvents events ->
                    { focus'
                        | status <- Showing
                        , events <- events
                    }

                ShowError error ->
                    { focus' | status <- Error error }

                _ ->
                    focus'


defaultFocus : Focus
defaultFocus = Focus Start []


view : Address Action -> Model -> Focus -> Html
view address model focus =
    let
        language =
            model.useLanguage

        trans =
            AuditsText.translate language
       
        formatDate =
            text << model.formatDate "Y M j" 

        makeRow audit =
            tr []
                [ td [] [ formatDate audit.timestamp ] 
                , td [] [ small [] [ text audit.principal ] ]
                , td [] [ text audit.type' ]
                , td []
                    [ text <| withDefault "" <| Dict.get "message" audit.data
                    , trans AuditsText.TableDataRemoteAddress
                    , text <| withDefault "" <| Dict.get "remoteAddress" audit.data
                    ]
                ]
        
        result =
            case focus.status of
                Error error -> 
                    p []
                      [ showError language error ]
                
                _ ->
                    p [] []

    
    in
        div [ class "csrs-auth-login container" ]
            [ div [ class "well well-sm" ]
                [ div []
                    [ h2 [] [ trans AuditsText.Title ]
                    , div [ class "row" ]
                        [ div [ class "col-md-5" ]
                            [ h4 [] [ trans AuditsText.FilterTitle ]
                            , p [ class "input-group" ]
                                [ span [ class "input-group-addon" ] [ trans AuditsText.FilterFrom ]
                                , input 
                                    [ type' "date"
                                    , class "input-sm form-control"
                                    ] []
                                , span [ class "input-group-addon" ] [ trans AuditsText.FilterTo ]
                                , input 
                                    [ type' "date"
                                    , class "input-sm form-control"
                                    ] [] 
                                ]
                            ]
                        ]
                    , result
                    , table [ class "table table-condensed table-striped table-bordered table-responsive" ]
                        [ thead []
                            [ tr []
                                [ th [ {- onClick "predicate = 'timestamp'; reverse=!reverse" -} ] [ trans AuditsText.TableHeaderDate ]
                                , th [ {- onClick "predicate = 'principal'; reverse=!reverse" -} ] [ trans AuditsText.TableHeaderPrincipal ]
                                , th [ {- onClick "predicate = 'type'; reverse=!reverse" -} ] [ trans AuditsText.TableHeaderStatus ]
                                , th [ {- onClick "predicate = 'data.message'; reverse=!reverse" -} ] [ trans AuditsText.TableHeaderData ]
                                ]
                            ]
                        , tbody []
                            <| List.map makeRow focus.events
                        ]
                    ]
                ]
            ]


menuItem : Address Action -> Model -> Maybe Focus -> Maybe Html
menuItem address model focus =
    let
        menu =
            li [ classList [ ( "active", focus /= Nothing ) ] ]
                [ a [ onClick address FetchAll
                    , id "navbar-admin-audits"
                    ]
                    [ glyphicon "bell" 
                    , text unbreakableSpace
                    , AuditsText.translate model.useLanguage AuditsText.Title 
                    ]
                ]
 
    in
        Maybe.map (always menu) model.currentUser
