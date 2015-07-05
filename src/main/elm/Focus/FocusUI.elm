module Focus.FocusUI where

import String exposing (split)
import Home.HomeFocus as HomeFocus
import Account.AccountFocus as AccountFocus
import Error.ErrorFocus as ErrorFocus
import Admin.AdminFocus as AdminFocus
import Tasks.TasksFocus as TasksFocus
import Signal exposing (Mailbox, mailbox, Address, forwardTo)
import String exposing (uncons)
import Http exposing (uriDecode, uriEncode)
import Language.LanguageService exposing (Language(..))
import Html exposing (Html)
import Maybe exposing (withDefault)
import History exposing (hash, setPath, replacePath)

type DesiredLocation
    = ReplacePath String
    | SetPath String

type Focus
    = Home HomeFocus.Focus
    | Account AccountFocus.Focus
    | Admin AdminFocus.Focus
    | Tasks TasksFocus.Focus
    | Error 

type Action
    = SwitchFocus Focus
    | SwitchFocusFromPath Focus
    | AccountAction AccountFocus.Action
    | HomeAction HomeFocus.Action
    | AdminAction AdminFocus.Action
    | TasksAction TasksFocus.Action
    | NoOp

type alias Hash = String

type alias Model a =
    { a
        | focus : Focus
        , desiredLocation : Maybe DesiredLocation
    }


init : m -> Model m
init model =
    let
        model' = { model | focus = initialFocus }

    in
        { model' | 
            desiredLocation = Nothing
        }


homeFocus : Focus -> Maybe HomeFocus.Focus
homeFocus focus =
    case focus of
        Home hf -> Just hf
        _ -> Nothing


accountFocus : Focus -> Maybe AccountFocus.Focus
accountFocus focus =
    case focus of
        Account af -> Just af
        _ -> Nothing


adminFocus : Focus -> Maybe AdminFocus.Focus
adminFocus focus =
    case focus of
        Admin af -> Just af
        _ -> Nothing


tasksFocus : Focus -> Maybe TasksFocus.Focus
tasksFocus focus =
    case focus of
        Tasks af -> Just af
        _ -> Nothing


focusActions : Mailbox Action
focusActions = mailbox NoOp


initialFocus : Focus
initialFocus = Home HomeFocus.Home 


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

                (AccountAction accountAction, Account accountFocus) ->
                    (Maybe.map Account <| AccountFocus.updateFocus accountAction <| Just accountFocus, SetPath)

                (AccountAction accountAction, _) ->
                    (Maybe.map Account <| AccountFocus.updateFocus accountAction Nothing, SetPath)

                (HomeAction homeAction, Home homeFocus) ->
                    (Maybe.map Home <| HomeFocus.updateFocus homeAction <| Just homeFocus, SetPath)
                
                (HomeAction homeAction, _) ->
                    (Maybe.map Home <| HomeFocus.updateFocus homeAction Nothing, SetPath)

                (AdminAction adminAction, Admin adminFocus) ->
                    (Maybe.map Admin <| AdminFocus.updateFocus adminAction <| Just adminFocus, SetPath)
                
                (AdminAction adminAction, _) ->
                    (Maybe.map Admin <| AdminFocus.updateFocus adminAction Nothing, SetPath)
                
                (TasksAction tasksAction, Tasks tasksFocus) ->
                    (Maybe.map Tasks <| TasksFocus.updateFocus tasksAction <| Just tasksFocus, SetPath)
                
                (TasksAction tasksAction, _) ->
                    (Maybe.map Tasks <| TasksFocus.updateFocus tasksAction Nothing, SetPath)
                
                (_, _) ->
                    (Nothing, ReplacePath)

    in
        { model
            | focus <- withDefault model.focus focus'
            , desiredLocation <- Maybe.map ( pathUpdater << focus2hash ) focus'
        }


render : Model m -> Language -> Html
render model language =
    case model.focus of
        Home homeFocus ->
            HomeFocus.renderFocus language
        
        Error ->
            ErrorFocus.render language
        
        Account accountFocus ->
            AccountFocus.renderFocus (forwardTo focusActions.address AccountAction) accountFocus language
        
        Admin adminFocus ->
            AdminFocus.renderFocus (forwardTo focusActions.address AdminAction) adminFocus language

        Tasks tasksFocus ->
            TasksFocus.renderFocus (forwardTo focusActions.address TasksAction) tasksFocus language


renderMenus : Focus -> Language -> List Html
renderMenus focus language =
    [ HomeFocus.renderMenu 
        (forwardTo focusActions.address HomeAction)
        (homeFocus focus)
        language
    , TasksFocus.renderMenu
        (forwardTo focusActions.address TasksAction)
        (tasksFocus focus)
        language
    , AccountFocus.renderMenu
        (forwardTo focusActions.address AccountAction)
        (accountFocus focus)
        language
    , AdminFocus.renderMenu
        (forwardTo focusActions.address AdminAction)
        (adminFocus focus)
        language
    ]
