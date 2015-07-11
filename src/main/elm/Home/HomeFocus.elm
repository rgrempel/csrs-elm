module Home.HomeFocus where

import Home.HomeTypes as HomeTypes exposing (..)

import Html exposing (Html, div, button, text, span, h1, p, ul, li, a)
import Html.Events exposing (onClick)
import Html.Attributes exposing (href, class, key, classList)
import Html.Util exposing (glyphicon, unbreakableSpace)
import Signal exposing (Address)
import Language.LanguageService exposing (Language(..))
import Account.AccountService as AccountService exposing (User)
import Focus.FocusTypes exposing (address, Action(FocusAccount))
import Account.AccountTypes exposing (Action(FocusSettings))

import Home.HomeText as HomeText


hash2focus : List String -> Maybe Focus
hash2focus hashList =
    Just Home


focus2hash : Focus -> List String
focus2hash focus = []


updateFocus : HomeTypes.Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    case action of
        FocusHome -> Just Home
        _ -> focus


renderFocus : Maybe User -> Language -> Html
renderFocus user language =
    let 
        trans = 
            HomeText.translate language

        loginHtml =
            case user of
                Just u ->
                    [ div [ class "alert alert-success" ]
                        [ trans (HomeText.LoggedInAs u.login) ]
                    ]

                _ ->
                    []
   
        thingsMembersCanDo =
            case user of
                Just u ->
                    [ ul []
                        [ li []
                            [ a [ onClick address <| FocusAccount FocusSettings ]
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


renderMenu : Address HomeTypes.Action -> Maybe Focus -> Language -> Html
renderMenu address focus language =
    let 
        trans = HomeText.translate language

    in
        li [ classList [ ( "active", focus /= Nothing ) ] ]
            [ a [ onClick address FocusHome ]
                [ glyphicon "home"
                , text unbreakableSpace
                , trans HomeText.MenuItem
                ]
            ]
