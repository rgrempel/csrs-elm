module View.Error where

import Html exposing (Html, div, button, text, span, h1, p, ul, li)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, key)

import View.Error.Language as EL
import Action exposing (Action)
import Model exposing (Model)

view : Signal.Address Action -> Model -> Html
view address model =
    let 
        trans = EL.translate model.useLanguage

    in
        div [ class "error-page container" ]
            [ div [ class "well well-sm" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-4" ]
                        [ span [ class "csrs-logo img-responsive img-rounded" ] []
                        ]
                    , div [ class "col-md-8" ]
                        [ h1 [] [ trans EL.Title ] -- errors.title
                    ]
                ]
            ]
        ]

