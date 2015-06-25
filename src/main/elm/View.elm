module View where

import Html exposing (Html, div)
import Html.Attributes exposing (key)
import Action exposing (Action)
import Model exposing (Model)
import Model.Focus exposing (Focus(Home, Account))

import View.Home
import View.NavBar
import View.Account
import View.Error

view : Signal.Address Action -> Model -> Html
view address model =
    div []
    [ View.NavBar.view address model
    , case model.focus of
        Home -> View.Home.view address model
        Error -> View.Error.view address model
        Account accountFocus -> View.Account.view accountFocus address model
    ]
