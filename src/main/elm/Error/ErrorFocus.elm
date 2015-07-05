module Error.ErrorFocus where

import Html exposing (Html, div, button, text, span, h1, p, ul, li)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, key)

import Language.LanguageService exposing (Language)

import Error.ErrorText as ErrorText


render : Language -> Html
render language =
    let 
        trans = ErrorText.translate language

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

