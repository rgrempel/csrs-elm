module View.Home where

import Html exposing (Html, div, button, text, span, h1, p, ul, li)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, key)

import View.Home.Language as HL
import Model.Translation 
import Model.Translation.Language as TL
import Action exposing (Action)
import Model exposing (Model)

view : Signal.Address Action -> Model -> Html
view address model =
    let 
        trans = HL.translate model.useLanguage

    in
        div [ class "main container" ]
            [ div [ class "well well-sm" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-4" ]
                        [ span [ class "csrs-logo img-responsive img-rounded" ] []
                        ]
                    , div [ class "col-md-8" ]
                        [ h1 [] [ trans HL.Title ] -- csrs.main.title
                        , p [ class "lead" ] [ trans HL.Subtitle ] -- csrs.main.subtitle
                        ]
                    ]
                ]
            ]

