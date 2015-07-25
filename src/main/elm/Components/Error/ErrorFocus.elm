module Components.Error.ErrorFocus where

import AppTypes exposing (..)
import Route.RouteService exposing (PathAction(..))

import Components.Error.ErrorTypes exposing (..)
import Components.Error.ErrorText as ErrorText

import Signal exposing (Address)
import Html exposing (Html, div, button, text, span, h1, p, ul, li)
import Html.Attributes exposing (class, key)


-- This is display only ... don't change the URL
path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' = Nothing


view : Address Action -> Model -> Focus -> Html
view address model focus =
    let 
        trans = ErrorText.translate model.useLanguage

    in
        div [ class "error-page container" ]
            [ div [ class "well well-sm" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-4" ]
                        [ span [ class "csrs-logo img-responsive img-rounded" ] []
                        ]
                    , div [ class "col-md-8" ]
                        [ h1 [] [ trans ErrorText.Title ] -- errors.title
                    ]
                ]
            ]
        ]

