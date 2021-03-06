module Html.Util where

import String exposing (fromChar)
import Char exposing (fromCode)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onWithOptions, Options, defaultOptions)
import Http
import Html.UtilText as UtilText exposing (translate)
import Language.LanguageTypes exposing (Language)
import Json.Decode
import Signal exposing (Address, message)


showError : Language -> Http.Error -> Html
showError language error =
    let
        trans =
            translate language

        content =
            case error of
                Http.Timeout ->
                    [ p [] [ trans error ] ]

                Http.NetworkError ->
                    [ p [] [ trans error ] ]

                Http.UnexpectedPayload err ->
                    [ p [] [ trans error ]
                    , p [] [ text err ]
                    ]

                Http.BadResponse err errText ->
                    [ p [] [ trans error ]
                    , p [] [ text (toString err) ]
                    , p [] [ text errText ]
                    ]

    in
        div
            [ class "alert alert-danger" ]
            content


preventDefault : Options
preventDefault =
    { defaultOptions | preventDefault <- True }


onlyOnSubmit : Address a -> a -> Attribute
onlyOnSubmit addr msg =
    onWithOptions "submit" preventDefault Json.Decode.value <| 
        always <| message addr msg


unbreakableSpace : String
unbreakableSpace = String.fromChar(Char.fromCode(160))


dataToggle : String -> Attribute
dataToggle action = attribute "data-toggle" action 


dataTarget : String -> Attribute
dataTarget action = attribute "data-target" action 


role : String -> Attribute
role theRole = attribute "role" theRole


glyphicon : String -> Html
glyphicon which = span [ class ("glyphicon glyphicon-" ++ which) ] []


dropdownToggle : List Attribute -> List Html -> Html
dropdownToggle attributes = 
    a <|
        attributes ++
            [ class "dropdown-toggle"
            , dataToggle "dropdown"
    --        , href "#"
            ]


dropdownPointer : List Attribute -> List Html -> Html
dropdownPointer attrs =
    li <| [ class "dropdown pointer" ] ++ attrs


dropdownMenu : List Html -> Html
dropdownMenu = 
    ul [ class "dropdown-menu" ]

