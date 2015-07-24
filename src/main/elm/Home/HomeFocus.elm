module Home.HomeFocus where

import AppTypes exposing (..)
import Home.HomeTypes as HomeTypes exposing (..)
import Home.HomeText as HomeText
import Signal exposing (Address)
import Route.RouteService exposing (PathAction(..))
import Focus.FocusTypes as FocusTypes 
import Account.AccountTypes as AccountTypes 

import Html exposing (Html, div, button, text, span, h1, p, ul, li, a)
import Html.Events exposing (onClick)
import Html.Attributes exposing (href, class, key, classList)
import Html.Util exposing (glyphicon, unbreakableSpace)


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
                        [ class "alert alert-success" ]
                        [ trans ( HomeText.LoggedInAs u.login ) ]
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
                    [ div [ class "alert alert-warning" ] [ trans HomeText.BeenHereBefore ]
                    , div [ class "alert alert-warning" ] [ trans HomeText.NoAccount ]
                    ]

                _ ->
                    []


    in
        div [ class "main container" ]
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
            [ a [ onClick address FocusHome ]
                [ glyphicon "home"
                , text unbreakableSpace
                , trans HomeText.MenuItem
                ]
            ]
