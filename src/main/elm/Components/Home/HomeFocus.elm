module Components.Home.HomeFocus where

import AppTypes exposing (..)
import Route.RouteService exposing (PathAction(..))

import Components.FocusTypes as FocusTypes 
import Components.Account.AccountTypes as AccountTypes 
import Components.Home.HomeTypes as HomeTypes exposing (..)
import Components.Home.HomeText as HomeText

import Signal exposing (Address)
import Html exposing (Html, div, button, text, span, h1, p, ul, li, a)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Html.Util exposing (glyphicon, unbreakableSpace)


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
route list = Just FocusHome


path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' =
    if focus == Just focus'
        then Nothing
        else Just <| SetPath []


update : Action -> Maybe Focus -> Maybe Focus
update action focus =
    case action of
        FocusHome ->
            Just Home
        
        _ ->
            focus


view : Address Action -> Model -> Focus -> Html
view address model focus =
    let 
        trans = 
            HomeText.translate model.useLanguage

        user =
            model.currentUser

        loginHtml =
            case user of
                Just u ->
                    [ div 
                        [ class "alert alert-success"
                        , id "loggedInMessage"
                        ]
                        [ trans ( HomeText.LoggedInAs u.username ) ]
                    ]

                _ ->
                    []
   
        thingsMembersCanDo =
            case user of
                Just _ ->
                    [ ul []
                        [ li []
                            [ a [ onClick FocusTypes.address <| FocusTypes.FocusAccount AccountTypes.FocusSettings ]
                                [ trans HomeText.CheckMembershipInformation ]
                            ]
                        ]
                    ]

                _ ->
                    []

        thingsToDoIfNotLoggedIn =
            case user of
                Nothing ->
                    [ div
                        [ class "alert alert-warning"
                        , id "notLoggedInMessage"
                        ]
                        [ trans HomeText.BeenHereBefore ]
                    , div [ class "alert alert-warning" ] [ trans HomeText.NoAccount ]
                    ]

                _ ->
                    []


    in
        div [ class "main focus-home container" ]
            [ div [ class "well well-sm" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-4" ]
                        [ span [ class "csrs-logo img-responsive img-rounded" ] []
                        ]
                    , div [ class "col-md-8" ]
                        (List.concat
                            [ [ h1 [] [ trans HomeText.Title ]
                              , p [ class "lead" ] [ trans HomeText.Subtitle ]
                              ]
                              , loginHtml
                              , thingsMembersCanDo
                              , thingsToDoIfNotLoggedIn
                              , [trans HomeText.MoreInformation]
                            ]
                        )
                    ]
                ]
            ]


menu : Address Action -> Model -> Maybe Focus -> Html
menu address model focus =
    let 
        trans = HomeText.translate model.useLanguage

    in
        li [ classList [ ( "active", focus /= Nothing ) ] ]
            [ a
                [ onClick address FocusHome
                , id "navbar-link-home" 
                ]
                [ glyphicon "home"
                , text unbreakableSpace
                , trans HomeText.MenuItem
                ]
            ]
