module Components.FocusUI where

import AppTypes exposing (..)
import Language.LanguageUI as LanguageUI
import Route.RouteService as RouteService exposing (PathAction(..))

import Components.FocusTypes exposing (..)
import Components.Home.HomeTypes as HomeTypes
import Components.Home.HomeFocus as HomeFocus
import Components.Account.AccountFocus as AccountFocus
import Components.Admin.AdminFocus as AdminFocus
import Components.Tasks.TasksFocus as TasksFocus
import Components.Error.ErrorTypes as ErrorTypes
import Components.Error.ErrorFocus as ErrorFocus
import Components.NavBar.NavBarUI as NavBarUI

import Signal exposing (Mailbox, mailbox, Address, forwardTo)
import Html exposing (Html, div)
import Maybe exposing (withDefault)
import Task exposing (Task)


submodule : SubModule x (FocusModel x) Action
submodule =
    { initialModel = initialModel
    , actions = .signal actions
    , update = update
    , reaction = Just reaction
    , initialTask = Nothing
    }


initialModel : m -> FocusModel m
initialModel model = FocusModel (Home HomeTypes.Home) model


reaction : Action -> FocusModel x -> Maybe (Task () ())
reaction action model =
    case action of
        FocusAccount action ->
            AccountFocus.reaction (forward FocusAccount) action (accountFocus model.focus)

        _ ->
            Nothing


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
                    (HomeFocus.path (homeFocus focus) subfocus)

                Error subfocus ->
                    Nothing 

                Account subfocus ->
                    prepend "account" (AccountFocus.path (accountFocus focus) subfocus)

                Admin subfocus ->
                    prepend "admin" (AdminFocus.path (adminFocus focus) subfocus)

                Tasks subfocus ->
                    prepend "tasks" (TasksFocus.path (tasksFocus focus) subfocus)


{-| Given a new focus and an old focus, calculate whether we should
    set or replace the path.
-}
delta2path : (Model, Model) -> List String -> Maybe PathAction 
delta2path delta current =
    let
        focus =
            .focus (fst delta)

        focus' = 
            .focus (snd delta)
        
        action =
            path focus focus'

        checkCurrent pathAction =
            if current == RouteService.return pathAction
                then Nothing
                else (Just pathAction)

    in
        action `Maybe.andThen` checkCurrent


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
            Just <| FocusError ErrorTypes.FocusError


update : Action -> FocusModel x -> FocusModel x
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
                
                FocusError subaction ->
                    Maybe.map Error <| ErrorFocus.update subaction (errorFocus model.focus)

                _ ->
                    Nothing

    in
        {model | focus <- withDefault model.focus focus'}


forward : (a -> Action) -> Address a
forward = forwardTo actions.address


{-| Creates the NavBar, and then generates whatever virtual page we're on.
-}
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
