module Focus.FocusUI where

import Focus.FocusTypes exposing (..)
import AppTypes exposing (..)

import Home.HomeTypes as HomeTypes
import Home.HomeFocus as HomeFocus
import Account.AccountFocus as AccountFocus
import Admin.AdminFocus as AdminFocus
import Tasks.TasksFocus as TasksFocus
import Error.ErrorTypes as ErrorTypes
import Error.ErrorFocus as ErrorFocus
import NavBar.NavBarUI as NavBarUI
import Language.LanguageUI as LanguageUI
import Route.RouteService as RouteService exposing (PathAction(..))

import Signal exposing (Mailbox, mailbox, Address, forwardTo)
import Html exposing (Html, div)
import Maybe exposing (withDefault)
import Task exposing (Task)


initialModel : m -> FocusModel m
initialModel model = FocusModel (Home HomeTypes.Home) model


reaction : Action -> Maybe (Task () ())
reaction action =
    case action of
        FocusAccount action ->
            AccountFocus.reaction (forward FocusAccount) action

        _ ->
            Nothing


deltaReaction : (Model, Model) -> Maybe (Task () ())
deltaReaction delta =
    let
        action =
            path (.focus (fst delta)) (.focus (snd delta))

    in
        Maybe.map RouteService.do action
            

{-| Given a new focus and an old focus, calculate whether we should
    set or replace the path.
-}
path : Focus -> Focus -> Maybe PathAction 
path focus focus' =
    let
        prepend prefix =
            Maybe.map (RouteService.map ((::) prefix))
    
    in
        if focus == focus'
            then Nothing
            else case focus' of
                Home subfocus ->
                    prepend "home" (HomeFocus.path (homeFocus focus) subfocus)

                Error subfocus ->
                    prepend "error" (ErrorFocus.path (errorFocus focus) subfocus)

                Account subfocus ->
                    prepend "account" (AccountFocus.path (accountFocus focus) subfocus)

                Admin subfocus ->
                    prepend "admin" (AdminFocus.path (adminFocus focus) subfocus)

                Tasks subfocus ->
                    prepend "tasks" (TasksFocus.path (tasksFocus focus) subfocus)


route : List String -> Maybe Action
route hash =
    case hash of
        first :: rest ->
            case first of
                "" ->
                    Maybe.map FocusHome <| HomeFocus.route rest
                
                "account" ->
                    Maybe.map FocusAccount <| AccountFocus.route rest
                
                "admin" ->
                    Maybe.map FocusAdmin <| AdminFocus.route rest

                "tasks" ->
                    Maybe.map FocusTasks <| TasksFocus.route rest
                
                _ ->
                    Just <| FocusError ErrorTypes.FocusError

        _ ->
            Maybe.map FocusHome <| HomeFocus.route []


tasks : Signal (Maybe (Task () ()))
tasks = Signal.map (Maybe.map do << route) RouteService.routes


update : Action -> Model -> Model
update action model =
    let
        focus' =
            case action of
                FocusAccount subaction ->
                    Maybe.map Account <| AccountFocus.update subaction (accountFocus model.focus)

                FocusHome subaction ->
                    Maybe.map Home <| HomeFocus.update subaction (homeFocus model.focus)
                
                FocusAdmin subaction ->
                    Maybe.map Admin <| AdminFocus.update subaction (adminFocus model.focus)
                
                FocusTasks subaction ->
                    Maybe.map Tasks <| TasksFocus.update subaction (tasksFocus model.focus)
                 
                _ ->
                    Nothing

    in
        @focus (withDefault model.focus focus') model


forward : (a -> Action) -> Address a
forward = forwardTo actions.address


view : Model -> Html
view model =
    let
        menus =
            NavBarUI.view model
                [ HomeFocus.menu (forward FocusHome) model (homeFocus model.focus)
                , TasksFocus.menu (forward FocusTasks) model (tasksFocus model.focus)
                , AccountFocus.menu (forward FocusAccount) model (accountFocus model.focus)
                , AdminFocus.menu (forward FocusAdmin) model (adminFocus model.focus)
                , LanguageUI.menu model
                ]

        page =
            case model.focus of
                Home subfocus ->
                    HomeFocus.view (forward FocusHome) model subfocus
                     
                Error subfocus->
                    ErrorFocus.view (forward FocusError) model subfocus
                
                Account subfocus ->
                    AccountFocus.view (forward FocusAccount) model subfocus
                
                Admin subfocus ->
                    AdminFocus.view (forward FocusAdmin) model subfocus

                Tasks subfocus ->
                    TasksFocus.view (forward FocusTasks) model subfocus

    in
        div [] [ menus, page ]
