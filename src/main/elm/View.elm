module View where

import Html exposing (Html, div)
import Html.Attributes exposing (key)
import Types exposing (Action, Model)
import Focus.Types exposing (Focus(Home, Account))

import Home.View
import NavBar.View
import Account.View
import Error.View

view : Signal.Address Action -> Model -> Html
view address model =
    div []
    [ NavBar.View.view address model
    , case model.focus of
        Home -> Home.View.view address model
        Error -> Error.View.view address model
        Account accountFocus -> Account.View.view accountFocus address model
    ]
