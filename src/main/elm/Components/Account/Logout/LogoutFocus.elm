module Components.Account.Logout.LogoutFocus where

import AppTypes exposing (..)
import Account.AccountService as AccountService
import Route.RouteService exposing (PathAction(..))

import Components.Account.Logout.LogoutTypes as LogoutTypes exposing (..)
import Components.Account.Logout.LogoutText as LogoutText
import Components.FocusTypes as FocusTypes
import Components.Home.HomeTypes as HomeTypes

import Signal exposing (message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task)
import Task.Util exposing (..)


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
route hashList = Just FocusBlank


path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' =
    if focus == Nothing
        then Just <| SetPath []
        else Nothing


reaction : Address LogoutTypes.Action -> LogoutTypes.Action -> Maybe Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        AttemptLogout ->
            Just <|
                dispatch AccountService.attemptLogout address FocusError (always FocusSuccess)

        FocusSuccess ->
            Just <| 
                FocusTypes.do <| 
                    FocusTypes.FocusHome HomeTypes.FocusHome

        _ ->
            Nothing


update : LogoutTypes.Action -> Maybe Focus -> Maybe Focus
update action focus =
    let
        focus' =
            withDefault defaultFocus focus 

    in
        Just <|
            case action of
                FocusError error ->
                    {focus' | status <- Error error}

                FocusSuccess ->
                    {focus' | status <- LoggedOut}

                _ -> focus'


defaultFocus : Focus
defaultFocus =
    { status = Start
    }


view : Address LogoutTypes.Action -> Model -> Focus -> Html
view address model focus =
    let
        trans =
            LogoutText.translate model.language.useLanguage
 
    in
        div [ class "csrs-auth-logout container" ]
            [ div [ class "well well-sm" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-4 col-md-offset-4" ]
                        [ h1 [] [ trans LogoutText.Title ]
                        ]
                    ]
                ]
            ]


menuItem : Address LogoutTypes.Action -> Model -> Maybe Focus -> Maybe Html
menuItem address model focus =
    let
        menu =
            li [ classList [ ( "active", focus /= Nothing ) ] ]
                [ a [ onClick address AttemptLogout
                    , id "navbar-link-account-logout"
                    ]
                    [ glyphicon "log-out" 
                    , text unbreakableSpace
                    , LogoutText.translate model.language.useLanguage LogoutText.Title 
                    ]
                ]

    in
        -- Only show menu if user logged in
        Maybe.map (always menu) model.account.currentUser

