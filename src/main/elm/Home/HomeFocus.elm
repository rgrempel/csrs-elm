module Home.HomeFocus where

import Html exposing (Html, div, button, text, span, h1, p, ul, li, a)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, key, classList)
import Html.Util exposing (glyphicon, unbreakableSpace)
import Signal exposing (Address)
import Language.LanguageService exposing (Language(..))

import Home.HomeText as HomeText

type Focus
    = Home

type Action
    = FocusHome


hash2focus : List String -> Maybe Focus
hash2focus hashList =
    Just Home


focus2hash : Focus -> List String
focus2hash focus = []


updateFocus : Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    case action of
        FocusHome -> Just Home
        _ -> focus


renderFocus : Language -> Html
renderFocus language =
    let 
        trans = HomeText.translate language

    in
        div [ class "main container" ]
            [ div [ class "well well-sm" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-4" ]
                        [ span [ class "csrs-logo img-responsive img-rounded" ] []
                        ]
                    , div [ class "col-md-8" ]
                        [ h1 [] [ trans HomeText.Title ]
                        , p [ class "lead" ] [ trans HomeText.Subtitle ]
                        ]
                    ]
                ]
            ]


renderMenu : Address Action -> Maybe Focus -> Language -> Html
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
