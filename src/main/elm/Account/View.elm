module Account.View where

import Html exposing (Html, h1, text, div)
import Html.Attributes exposing (class)
import Focus.Types exposing (..)
import Types exposing (Action, Model)
import Account.Login.View

view : AccountFocus -> Signal.Address Action -> Model -> Html
view focus address model =
    let 
        v s =
            div [ class "container" ]
                [ h1 [] [ text s ]
                ]

    in
        case focus of
            Settings -> v "Settings"
            Password -> v "Password"
            Sessions -> v "Sessions"
            Logout -> v "Logout"
            Login credentials -> Account.Login.View.view address credentials model
            Register -> v "Register"
