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
                AccountService.attemptLogout
                `Task.andThen` (\user ->
                    Signal.send address FocusSuccess
                ) `Task.onError` (\error ->
                    Signal.send address (FocusError error)
                )

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
                    {focus' | logoutStatus <- LogoutError error}

                FocusSuccess ->
                    {focus' | logoutStatus <- LogoutSuccess}

                _ -> focus'


defaultFocus : Focus
defaultFocus =
    { logoutStatus = LogoutNotAttempted
    }


view : Address LogoutTypes.Action -> Model -> Focus -> Html
view address model focus =
    let
        trans =
            LogoutText.translate model.useLanguage
 
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


menuItem : Address LogoutTypes.Action -> Model -> Maybe Focus -> Html
menuItem address model focus =
    li [ classList [ ( "active", focus /= Nothing ) ] ]
        [ a [ onClick address AttemptLogout
            , id "navbar-link-account-logout"
            ]
            [ glyphicon "log-out" 
            , text unbreakableSpace
            , LogoutText.translate model.useLanguage LogoutText.Title 
            ]
        ]

