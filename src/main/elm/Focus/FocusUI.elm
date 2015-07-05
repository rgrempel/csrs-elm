module Focus.FocusUI where

import String exposing (split)
import Home.HomeFocus as HomeFocus
import Account.AccountFocus as AccountFocus
import Error.ErrorFocus as ErrorFocus
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
    | Error 

type Action
    = SwitchFocus Focus
    | SwitchFocusFromPath Focus
    | AccountAction AccountFocus.Action
    | HomeAction HomeFocus.Action
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
            desiredLocation = Just <| ReplacePath <| focus2hash initialFocus
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

                (_, _) ->
                    (Nothing, ReplacePath)

    in
        { model
            | focus <- withDefault model.focus focus'
            , desiredLocation <- Just <| pathUpdater <| focus2hash <| withDefault model.focus focus'
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


renderMenus : Focus -> Language -> List Html
renderMenus focus language =
    [ HomeFocus.renderMenu 
        (forwardTo focusActions.address HomeAction)
        (homeFocus focus)
        language
    , AccountFocus.renderMenu
        (forwardTo focusActions.address AccountAction)
        (accountFocus focus)
        language
    ]
