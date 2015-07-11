module Focus.FocusUI where

import Focus.FocusTypes exposing (..)
import String exposing (split)
import Account.AccountService as AccountService

import Home.HomeTypes as HomeTypes
import Account.AccountTypes as AccountTypes
import Admin.AdminTypes as AdminTypes
import Tasks.TasksTypes as TasksTypes

import Home.HomeFocus as HomeFocus
import Account.AccountFocus as AccountFocus
import Admin.AdminFocus as AdminFocus
import Tasks.TasksFocus as TasksFocus
import Error.ErrorFocus as ErrorFocus

import Signal exposing (Mailbox, mailbox, Address, forwardTo)
import String exposing (uncons)
import Http exposing (uriDecode, uriEncode)
import Language.LanguageService exposing (Language)
import Html exposing (Html)
import Maybe exposing (withDefault)
import History exposing (hash, setPath, replacePath)
import Task exposing (Task)


type DesiredLocation
    = ReplacePath String
    | SetPath String

type alias Hash = String

type alias Model m =
    { m
        | focus : Focus
        , desiredLocation : Maybe DesiredLocation
    }


init : m -> Model m
init model = Model initialFocus Nothing model


homeFocus : Focus -> Maybe HomeTypes.Focus
homeFocus focus =
    case focus of
        Home hf -> Just hf
        _ -> Nothing


accountFocus : Focus -> Maybe AccountTypes.Focus
accountFocus focus =
    case focus of
        Account af -> Just af
        _ -> Nothing


adminFocus : Focus -> Maybe AdminTypes.Focus
adminFocus focus =
    case focus of
        Admin af -> Just af
        _ -> Nothing


tasksFocus : Focus -> Maybe TasksTypes.Focus
tasksFocus focus =
    case focus of
        Tasks af -> Just af
        _ -> Nothing


initialFocus : Focus
initialFocus = Home HomeTypes.Home 


hashPrefix : String
hashPrefix = "#!/"


hashSignal : Signal Action
hashSignal =
    Signal.map ( SwitchFocusFromPath << hash2focus ) hash


-- Remove initial characters from the string, as many as there are.
-- So, for "#!/", remove # if is first, then ! if it is next, etc.
removeAnyInitial : String -> String -> String
removeAnyInitial initial original =
    String.foldl removeInitial original initial


removeInitial : Char -> String -> String
removeInitial initial original =
    case uncons original of
        Just (first, rest) -> if first == initial then rest else original
        _ -> original


hash2focus : String -> Focus
hash2focus hash =
    let
        hashList =
            List.map uriDecode
                <| split "/"
                <| removeAnyInitial hashPrefix hash

    in
        withDefault Error <|
            case hashList of
                first :: rest ->
                    case first of
                        "" ->
                            Maybe.map Home <| HomeFocus.hash2focus rest
                        
                        "account" ->
                            Maybe.map Account <| AccountFocus.hash2focus rest
                        
                        "admin" ->
                            Maybe.map Admin <| AdminFocus.hash2focus rest

                        "tasks" ->
                            Maybe.map Tasks <| TasksFocus.hash2focus rest
                        
                        _ ->
                            Nothing

                _ ->
                    Nothing


focus2hash : Focus -> String
focus2hash focus =
    let
        hashList =
            case focus of
                Home homeFocus ->
                    "" :: HomeFocus.focus2hash homeFocus

                Error ->
                    ["error"]

                Account accountFocus ->
                    "account" :: AccountFocus.focus2hash accountFocus

                Admin adminFocus ->
                    "admin" :: AdminFocus.focus2hash adminFocus

                Tasks tasksFocus ->
                    "tasks" :: TasksFocus.focus2hash tasksFocus

    in
        hashPrefix
        ++
        List.foldl
            ( \iter accum -> accum ++ if accum == "" then (uriEncode iter) else "/" ++ (uriEncode iter) )
            ""
            hashList


tasks : Signal (Maybe (Task () ()))
tasks = Signal.map reaction (.signal actions)
    

reaction : Action -> Maybe (Task () ())
reaction action =
    case action of
        FocusAccount action ->
            AccountFocus.reaction action

        _ ->
            Nothing


update : Action -> Model m -> Model m
update action model =
    let
        (focus', pathUpdater) =
            case (action, model.focus) of
                (SwitchFocus focus, _) ->
                    (Just focus, SetPath) 

                -- If the focus change is coming from the path, then we set up a
                -- possible ReplacePath action, rather than SetPath. That way,
                -- we'll get our canonical path, but we won't update the history,
                -- since clearly the old path got us here too.
                (SwitchFocusFromPath focus, _) ->
                    (Just focus, ReplacePath)

                (FocusAccount accountAction, Account accountFocus) ->
                    (Maybe.map Account <| AccountFocus.updateFocus accountAction <| Just accountFocus, SetPath)

                (FocusAccount accountAction, _) ->
                    (Maybe.map Account <| AccountFocus.updateFocus accountAction Nothing, SetPath)

                (FocusHome homeAction, Home homeFocus) ->
                    (Maybe.map Home <| HomeFocus.updateFocus homeAction <| Just homeFocus, SetPath)
                
                (FocusHome homeAction, _) ->
                    (Maybe.map Home <| HomeFocus.updateFocus homeAction Nothing, SetPath)

                (FocusAdmin adminAction, Admin adminFocus) ->
                    (Maybe.map Admin <| AdminFocus.updateFocus adminAction <| Just adminFocus, SetPath)
                
                (FocusAdmin adminAction, _) ->
                    (Maybe.map Admin <| AdminFocus.updateFocus adminAction Nothing, SetPath)
                
                (FocusTasks tasksAction, Tasks tasksFocus) ->
                    (Maybe.map Tasks <| TasksFocus.updateFocus tasksAction <| Just tasksFocus, SetPath)
                
                (FocusTasks tasksAction, _) ->
                    (Maybe.map Tasks <| TasksFocus.updateFocus tasksAction Nothing, SetPath)
                
                (_, _) ->
                    (Nothing, ReplacePath)

    in
        { model
            | focus <- withDefault model.focus focus'
            , desiredLocation <- Maybe.map ( pathUpdater << focus2hash ) focus'
        }


forward : (a -> Action) -> Address a
forward = forwardTo actions.address


render : { a | currentUser : Maybe AccountService.User, focus : Focus } -> Language -> Html
render model language =
    case model.focus of
        Home homeFocus ->
            HomeFocus.renderFocus model.currentUser language
        
        Error ->
            ErrorFocus.render language
        
        Account accountFocus ->
            AccountFocus.renderFocus (forward FocusAccount) accountFocus language
        
        Admin adminFocus ->
            AdminFocus.renderFocus (forward FocusAdmin) adminFocus language

        Tasks tasksFocus ->
            TasksFocus.renderFocus (forward FocusTasks) tasksFocus language


renderMenus : Focus -> Language -> List Html
renderMenus focus language =
    [ HomeFocus.renderMenu (forward FocusHome) (homeFocus focus) language
    , TasksFocus.renderMenu (forward FocusTasks) (tasksFocus focus) language
    , AccountFocus.renderMenu (forward FocusAccount) (accountFocus focus) language
    , AdminFocus.renderMenu (forward FocusAdmin) (adminFocus focus) language
    ]
