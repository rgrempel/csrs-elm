module Html.Util where

import String exposing (fromChar)
import Char exposing (fromCode)
import Html exposing (..)
import Html.Attributes exposing (..)


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


dropdownToggle : List Html -> Html
dropdownToggle = 
    a
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

