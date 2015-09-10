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
import List exposing (all, isEmpty, sortWith)
import Date exposing (toTime)
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
                        , events <- sortedEvents focus'.sortBy focus'.sortReversed events
                    }

                ShowError error ->
                    { focus' | status <- Error error }

                ClickedHeader value ->
                    let
                        reverse =
                            if focus'.sortBy == value
                                then not focus'.sortReversed
                                else focus'.sortReversed

                    in
                        { focus'
                            | sortBy <- value
                            , sortReversed <- reverse
                            , events <- sortedEvents value reverse focus'.events
                        }

                _ ->
                    focus'


sortedEvents : Header -> Bool -> List AuditEvent -> List AuditEvent
sortedEvents sortBy sortReversed events =
    let
        sorter a b =
            possiblyReverse <|
                case sortBy of
                    Timestamp -> compare (toTime a.timestamp) (toTime b.timestamp)
                    Principal -> compare a.principal b.principal
                    Type -> compare a.type' b.type'
            
        possiblyReverse order =
            if sortReversed
                then case order of
                    LT -> GT
                    EQ -> EQ
                    GT -> LT
                else order

    in
        sortWith sorter events


view : Address Action -> Model -> Focus -> Html
view address model focus =
    let
        language =
            model.language.useLanguage

        trans =
            AuditsText.translate language
       
        formatDate =
            text << model.language.formatDate "Y M j" 

        makeRow audit =
            let
                entry2html key value =
                    div []
                        -- TODO: Could translate some of the common keys
                        [ text <| key ++ ": " ++ value ]

            in
                tr [ key (toString audit.id) ]
                    [ td [] [ formatDate audit.timestamp ] 
                    , td [] [ small [] [ text audit.principal ] ]
                    , td [] [ text audit.type' ]
                    , td [] <|
                        Dict.values <|
                            Dict.map entry2html audit.data
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
                                [ th [ onClick address (ClickedHeader Timestamp) ] [ trans AuditsText.TableHeaderDate ]
                                , th [ onClick address (ClickedHeader Principal) ] [ trans AuditsText.TableHeaderPrincipal ]
                                , th [ onClick address (ClickedHeader Type) ] [ trans AuditsText.TableHeaderStatus ]
                                , th [] [ trans AuditsText.TableHeaderData ]
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
                    , AuditsText.translate model.language.useLanguage AuditsText.Title 
                    ]
                ]
 
    in
        Maybe.map (always menu) model.account.currentUser
