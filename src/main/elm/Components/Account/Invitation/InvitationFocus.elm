module Components.Account.Invitation.InvitationFocus where

import AppTypes exposing (..)
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(Required, Email))
import Account.AccountService as AccountService
import Route.RouteService exposing (PathAction (..))

import Components.Account.Invitation.InvitationTypes as InvitationTypes exposing (..)
import Components.Account.Invitation.InvitationText as InvitationText
import Components.Account.Invitation.Register.RegisterFocus as RegisterFocus
import Components.Account.Invitation.ResetPassword.ResetPasswordFocus as ResetPasswordFocus

import Signal exposing (message, forwardTo)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace, showError)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task, andThen, onError)
import List exposing (all, isEmpty)
import Http


route : List String -> Maybe Action
route hashList = 
    case hashList of
        first :: rest ->
            Just <| FocusKey first

        _ ->
            Just <| FocusBlank


path : Maybe Focus -> Focus -> Maybe PathAction 
path focus focus' =
    let
        operation =
            if focus == Nothing
                then Just << SetPath
                else Just << ReplacePath

    in
        case focus' of
            Invitation subfocus ->
                case subfocus.key of
                    "" -> operation []
                    other -> operation [other]

            _ ->
                Nothing


reaction : Address InvitationTypes.Action -> InvitationTypes.Action -> Maybe (Task () ())
reaction address action =
    case action of
        FocusRegister subaction ->
            RegisterFocus.reaction (forwardTo address FocusRegister) subaction

        FocusResetPassword subaction ->
            ResetPasswordFocus.reaction (forwardTo address FocusResetPassword) subaction

        CheckInvitation key ->
            if isEmpty (checkRequired key) 
                then
                    Just <|
                        (AccountService.fetchInvitation key)
                        `andThen` 
                        (Signal.send address << FocusInvitationFound)
                        `onError` (\error ->
                            case error of
                                Http.BadResponse 404 _ ->
                                    Signal.send address FocusInvitationNotFound

                                _ ->
                                    Signal.send address (FocusError error)
                        )
                else
                    Nothing

        _ ->
            Nothing


update : InvitationTypes.Action -> Maybe Focus -> Maybe Focus
update action focus =
    let
        invitation =
            case focus of
                Just (Invitation subfocus) -> subfocus
                _ -> defaultFocus
 
    in
        case action of
            FocusRegister subaction ->
                Maybe.map Register <| RegisterFocus.update subaction <| focus `Maybe.andThen` registerFocus

            FocusResetPassword subaction ->
                Maybe.map ResetPassword <| ResetPasswordFocus.update subaction <| focus `Maybe.andThen` resetPasswordFocus 

            FocusKey key ->
                Just <| Invitation <| @key key invitation

            CheckInvitation key ->
                Just <| Invitation <| @status CheckingInvitation invitation

            FocusInvitationNotFound ->
                Just <| Invitation <| @status InvitationNotFound invitation

            FocusInvitationFound activation ->
                Just <| Invitation <| @status (InvitationFound activation) invitation

            FocusError error ->
                Just <| Invitation <| @status (Error error) invitation

            _ ->
                Just <| Invitation invitation


defaultFocus : InvitationFocus
defaultFocus = InvitationFocus "" InvitationStart


checkRequired : String -> List StringValidator
checkRequired = checkString [Required]


view : Address InvitationTypes.Action -> Model -> Focus -> Html
view address model focus =
    let
        forward = forwardTo address

    in
        case focus of
            Register subfocus ->
                RegisterFocus.view (forward FocusRegister) model subfocus

            ResetPassword subfocus ->
                ResetPasswordFocus.view (forward FocusResetPassword) model subfocus

            Invitation subfocus ->
                viewInvitation address model subfocus


viewInvitation : Address InvitationTypes.Action -> Model -> InvitationFocus -> Html
viewInvitation address model focus =
    let
        language =
            model.useLanguage
    
        trans =
            InvitationText.translate language

        wrap contents =
            div [ class "csrs-invitation container" ]
                [ div [ class "well well-sm" ]
                    [ div [ class "row" ]
                        [ div 
                            [ class "col-xs-12" ]
                            contents
                        ]
                    ]
                ]

        errors =
            case focus.status of
                InvitationStart -> []
                _ -> checkRequired focus.key

        failureMessage =
            case focus.status of
                InvitationNotFound ->
                    [ div [ class "alert alert-danger text-left" ]
                        [ h4 [] [ trans InvitationText.NotFound ]
                        , p [] [ trans InvitationText.TryAgain ]
                        ]
                    ]
                
                _ -> []

        errorMessage =
            case focus.status of
                Error error ->
                    [ showError language error ] 

                InvitationFound invitation ->
                    [ div [ class "alert alert-success" ]
                        [ text (toString invitation) ]
                    ]

                _ -> []

        in
            wrap <|
                [ h2 [] [ trans InvitationText.Title ]
                , p [] [ trans InvitationText.Blurb ]

                , Html.form
                    [ class "form"
                    , role "form"
                    , onSubmit address (CheckInvitation focus.key)
                    ]
                    [ div
                        [ classList
                            [ ("form-group", True)
                            , ("has-error", not <| isEmpty errors)
                            ]
                        ]
                        <|
                        [ label
                            [ for "invitation-key" ]
                            [ trans InvitationText.Key ]
                        , div
                            [ class "input-group" ]
                            [ input
                                [ id "invitation-key"
                                , type' "text"
                                , class "form-control"
                                , value focus.key
                                , on "input" targetValue <| (message address) << FocusKey
                                ] []
                            , span [ class "input-group-btn" ]
                                [ button
                                    [ type' "submit"
                                    , class "btn btn-primary"
                                    ]
                                    [ glyphicon "tag"
                                    , text unbreakableSpace
                                    , trans InvitationText.UseThisInvitation
                                    ]
                                ]
                            ]
                        ]
                        ++
                        ( List.map (helpBlock language) errors )
                    ]
                ]
                ++ failureMessage
                ++ errorMessage


