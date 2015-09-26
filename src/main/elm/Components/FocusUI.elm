module Components.FocusUI where

import AppTypes exposing (..)
import Language.LanguageUI as LanguageUI
import RouteHash exposing (HashUpdate)

import Components.FocusTypes exposing (..)
import Components.Home.HomeTypes as HomeTypes
import Components.Home.HomeFocus as HomeFocus
import Components.Account.AccountFocus as AccountFocus
import Components.Admin.AdminFocus as AdminFocus
import Components.Tasks.TasksFocus as TasksFocus
import Components.Error.ErrorTypes as ErrorTypes
import Components.Error.ErrorFocus as ErrorFocus
import Components.NavBar.NavBarUI as NavBarUI

import Html exposing (Html, div)
import Maybe exposing (withDefault)
import Task exposing (Task)


submodule : SubModule FocusModel Action
submodule =
    { initialModel = initialModel
    , actions = .signal actions
    , update = update
    , reaction = Just reaction
    , initialTask = Nothing
    }


account =
    superComponent <|
        MakeComponent "account" FocusAccount Account accountFocus AccountFocus.subcomponent

admin =
    superComponent <|
        MakeComponent "admin" FocusAdmin Admin adminFocus AdminFocus.subcomponent

error =
    superComponent <|
        MakeComponent "error" FocusError Error errorFocus ErrorFocus.subcomponent

home =
    superComponent <|
        MakeComponent "" FocusHome Home homeFocus HomeFocus.subcomponent

tasks =
    superComponent <|
        MakeComponent "tasks" FocusTasks Tasks tasksFocus TasksFocus.subcomponent


initialModel : FocusModel
initialModel = FocusModel (Home HomeTypes.Home)


reaction : Action -> FocusModel -> Maybe (Task () ())
reaction action model =
    let
        focus =
            Just model.focus
    
    in
        case action of
            FocusAccount subaction ->
                account.reaction actions.address subaction focus 

            FocusAdmin subaction ->
                admin.reaction actions.address subaction focus

            FocusError subaction ->
                error.reaction actions.address subaction focus

            FocusHome subaction ->
                home.reaction actions.address subaction focus

            FocusTasks subaction ->
                tasks.reaction actions.address subaction focus

            _ ->
                Nothing


path : Focus -> Focus -> Maybe HashUpdate
path focus focus' =
    if focus == focus'
        then Nothing
        else case focus' of
            Home subfocus ->
                home.path (Just focus) subfocus

            Error subfocus ->
                error.path (Just focus) subfocus 

            Account subfocus ->
                account.path (Just focus) subfocus

            Admin subfocus ->
                admin.path (Just focus) subfocus

            Tasks subfocus ->
                tasks.path (Just focus) subfocus

            _ ->
                Nothing


{-| Given a new focus and an old focus, calculate whether we should
    set or replace the path.
-}
delta2path : Model -> Model -> Maybe HashUpdate 
delta2path model model' =
    path model.focus.focus model'.focus.focus


route : List String -> Maybe Action
route hash =
    Maybe.oneOf
        [ home.route hash
        , account.route hash
        , admin.route hash
        , tasks.route hash
        , Just (FocusError ErrorTypes.FocusError)
        ]


update : Action -> FocusModel -> FocusModel
update action model =
    let
        focus =
            Just model.focus

        focus' =
            case action of
                FocusAccount subaction ->
                    account.update subaction focus

                FocusHome subaction ->
                    home.update subaction focus
                
                FocusAdmin subaction ->
                    admin.update subaction focus
                
                FocusTasks subaction ->
                    tasks.update subaction focus
                
                FocusError subaction ->
                    error.update subaction focus

                _ ->
                    Nothing

    in
        {model | focus <- withDefault model.focus focus'}


{-| Creates the NavBar, and then generates whatever virtual page we're on.
-}
view : Model -> Html
view model =
    let
        focus =
            Just model.focus.focus

        menus =
            NavBarUI.view model <|
                List.filterMap identity
                    [ home.menu actions.address model focus
                    , tasks.menu actions.address model focus
                    , account.menu actions.address model focus
                    , admin.menu actions.address model focus
                    , error.menu actions.address model focus
                    ]
                ++ [ LanguageUI.menu model ]

        page =
            case model.focus.focus of
                Home subfocus ->
                    home.view actions.address model subfocus
                     
                Error subfocus->
                    error.view actions.address model subfocus
                
                Account subfocus ->
                    account.view actions.address model subfocus
                
                Admin subfocus ->
                    admin.view actions.address model subfocus

                Tasks subfocus ->
                    tasks.view actions.address model subfocus

    in
        div [] [ menus, page ]
