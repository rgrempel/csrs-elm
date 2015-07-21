module Account.Invitation.InvitationFocus where

import Account.Invitation.InvitationTypes as InvitationTypes exposing (..)
import Account.Invitation.InvitationText as InvitationText
import Account.Invitation.Register.RegisterFocus as RegisterFocus
import Account.Invitation.ResetPassword.ResetPasswordFocus as ResetPasswordFocus

import Signal exposing (message, forwardTo)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace, showError)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task, andThen, onError)
import Language.LanguageService exposing (Language)
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(Required, Email))
import List exposing (all, isEmpty)
import Account.AccountService as AccountService
import Http


hash2focus : List String -> Maybe Focus
hash2focus hashList = 
    case hashList of
        first :: rest ->
            Just <| Invitation <| @key first defaultFocus

        _ ->
            Just <| Invitation <| defaultFocus


focus2hash : Focus -> List String
focus2hash focus = 
    case focus of
        Invitation subfocus ->
            case subfocus.key of
                "" -> []
                other -> [other]

        _ -> []


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


updateFocus : InvitationTypes.Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    let
        invitation =
            case focus of
                Just (Invitation subfocus) -> subfocus
                _ -> defaultFocus
 
    in
        case (action, focus) of
            (FocusRegister subaction, Just (Register subfocus)) ->
                Maybe.map Register <| RegisterFocus.updateFocus subaction <| Just subfocus

            (FocusRegister subaction, _) ->
                Maybe.map Register <| RegisterFocus.updateFocus subaction <| Nothing

            (FocusResetPassword subaction, Just (ResetPassword subfocus)) ->
                Maybe.map ResetPassword <| ResetPasswordFocus.updateFocus subaction <| Just subfocus

            (FocusResetPassword subaction, _) ->
                Maybe.map ResetPassword <| ResetPasswordFocus.updateFocus subaction <| Nothing

            (FocusKey key, _) ->
                Just <| Invitation <| @key key invitation

            (CheckInvitation key, _) ->
                Just <| Invitation <| @status CheckingInvitation invitation

            (FocusInvitationNotFound, _) ->
                Just <| Invitation <| @status InvitationNotFound invitation

            (FocusInvitationFound activation, _) ->
                Just <| Invitation <| @status (InvitationFound activation) invitation

            (FocusError error, _) ->
                Just <| Invitation <| @status (Error error) invitation

            _ -> Just <| Invitation invitation


defaultFocus : InvitationFocus
defaultFocus = InvitationFocus "" InvitationStart


checkRequired : String -> List StringValidator
checkRequired = checkString [Required]


renderFocus : Address InvitationTypes.Action -> Focus -> Language -> Html
renderFocus address focus language =
    case focus of
        Register subfocus ->
            RegisterFocus.renderFocus
                (forwardTo address FocusRegister)
                subfocus
                language

        ResetPassword subfocus ->
            ResetPasswordFocus.renderFocus
                (forwardTo address FocusResetPassword)
                subfocus
                language

        Invitation subfocus ->
            renderInvitation address subfocus language


renderInvitation : Address InvitationTypes.Action -> InvitationFocus -> Language -> Html
renderInvitation address focus language =
    let
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


