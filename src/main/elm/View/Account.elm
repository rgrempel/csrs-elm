module View.Account where

import Html exposing (Html, h1, text, div)
import Html.Attributes exposing (class)
import Model.Focus exposing (..)
import Action exposing (Action)
import Model exposing (Model)
import View.Account.Login

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
            Login -> View.Account.Login.view address model
            Register -> v "Register"
