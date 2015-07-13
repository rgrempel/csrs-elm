module Account.Logout.LogoutFocus where

import Account.Logout.LogoutTypes as LogoutTypes exposing (..)

import Signal exposing (message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task)
import Language.LanguageService exposing (Language)
import Account.Logout.LogoutText as LogoutText
import Account.AccountService as AccountService
import Focus.FocusTypes as FocusTypes
import Home.HomeTypes as HomeTypes


hash2focus : List String -> Maybe Focus
hash2focus hashList = Just defaultFocus


focus2hash : Focus -> List String
focus2hash focus = []


reaction : Address LogoutTypes.Action -> LogoutTypes.Action -> Maybe (Task () ())
reaction address action =
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


updateFocus : LogoutTypes.Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    let
        focus' =
            withDefault defaultFocus focus 

    in
        Just <|
            case action of
                FocusError error ->
                    @logoutStatus (LogoutError error) focus'

                FocusSuccess ->
                    @logoutStatus LogoutSuccess focus'

                _ -> focus'


defaultFocus : Focus
defaultFocus =
    { logoutStatus = LogoutNotAttempted
    }


renderFocus : Address LogoutTypes.Action -> Focus -> Language -> Html
renderFocus address focus language =
    let
        trans =
            LogoutText.translate language
 
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


renderMenuItem : Address LogoutTypes.Action -> Maybe Focus -> Language -> Html
renderMenuItem address focus language =
    li [ classList [ ( "active", focus /= Nothing ) ] ]
        [ a [ onClick address AttemptLogout ]
            [ glyphicon "log-out" 
            , text unbreakableSpace
            , LogoutText.translate language LogoutText.Title 
            ]
        ]

