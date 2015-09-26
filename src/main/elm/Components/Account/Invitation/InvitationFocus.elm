module Components.Account.Invitation.InvitationFocus where

import AppTypes exposing (..)
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(Required, Email))
import Account.AccountService as AccountService
import RouteHash exposing (HashUpdate)

import Components.Account.Invitation.InvitationTypes as InvitationTypes exposing (..)
import Components.Account.Invitation.InvitationText as InvitationText
import Components.Account.Invitation.Register.RegisterFocus as RegisterFocus
import Components.Account.Invitation.ResetPassword.ResetPasswordFocus as ResetPasswordFocus
import Components.Account.Invitation.Register.RegisterTypes as RegisterTypes
import Components.Account.Invitation.ResetPassword.ResetPasswordTypes as ResetPasswordTypes

import Signal exposing (message, forwardTo)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace, showError, onlyOnSubmit)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task, andThen, onError)
import Task.Util exposing (..)
import List exposing (all, isEmpty)
import Http


subcomponent : SubComponent Action Focus 
subcomponent =
    { route = route
    , path = path
    , reaction = Just reaction
    , update = update
    , view = view
    , menu = Nothing 
    }


resetPassword =
    superComponent <|
        MakeComponent "" FocusResetPassword ResetPassword resetPasswordFocus ResetPasswordFocus.subcomponent

register =
    superComponent <|
        MakeComponent "" FocusRegister Register registerFocus RegisterFocus.subcomponent


route : List String -> Maybe Action
route hashList = 
    case hashList of
        first :: rest ->
            Just <| CheckInvitation first

        _ ->
            Just <| FocusBlank


path : Maybe Focus -> Focus -> Maybe HashUpdate 
path focus focus' =
    let
        operation =
            if focus == Nothing
                then Just << RouteHash.set
                else Just << RouteHash.replace

    in
        case focus' of
            Invitation subfocus ->
                case subfocus.key of
                    "" -> operation []
                    other -> operation [other]

            _ ->
                Nothing


reaction : Address InvitationTypes.Action -> InvitationTypes.Action -> Maybe InvitationTypes.Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        FocusRegister subaction ->
            register.reaction address subaction focus

        FocusResetPassword subaction ->
            resetPassword.reaction address subaction focus

        FocusInvitationFound activation ->
            if activation.userEmail.user == Nothing
                then Just <| Signal.send address <| FocusRegister <| RegisterTypes.FocusActivation activation
                else Just <| Signal.send address <| FocusResetPassword <| ResetPasswordTypes.FocusActivation activation

        CheckInvitation key ->
            let
                handleError error =
                    case error of
                        Http.BadResponse 404 _ ->
                            Signal.send address FocusInvitationNotFound

                        _ ->
                            Signal.send address (FocusError error)
            
            in
                if isEmpty (checkRequired key) 
                    then
                        Just <|
                            (AccountService.fetchInvitation key)
                                `andThen` notify address FocusInvitationFound
                                `onError` handleError
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
                register.update subaction focus

            FocusResetPassword subaction ->
                resetPassword.update subaction focus

            FocusKey key ->
                Just <| Invitation <| {invitation | key <- key}

            CheckInvitation key ->
                Just <| Invitation <|
                    { invitation
                        | status <- Checking
                        , key <- key
                    }

            FocusInvitationNotFound ->
                Just <| Invitation <| {invitation | status <- NotFound}

            FocusInvitationFound activation ->
                Just <| Invitation <| {invitation | status <- Found activation}

            FocusError error ->
                Just <| Invitation <| {invitation | status <- Error error}

            _ ->
                Just <| Invitation invitation


defaultFocus : InvitationFocus
defaultFocus = InvitationFocus "" Start


checkRequired : String -> List StringValidator
checkRequired = checkString [Required]


view : Address InvitationTypes.Action -> Model -> Focus -> Html
view address model focus =
    case focus of
        Register subfocus ->
            register.view address model subfocus

        ResetPassword subfocus ->
            resetPassword.view address model subfocus

        Invitation subfocus ->
            viewInvitation address model subfocus


viewInvitation : Address InvitationTypes.Action -> Model -> InvitationFocus -> Html
viewInvitation address model focus =
    let
        language =
            model.language.useLanguage
    
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
                Start -> []
                _ -> checkRequired focus.key

        failureMessage =
            case focus.status of
                NotFound ->
                    [ div [ class "alert invitation-not-found alert-danger text-left" ]
                        [ h4 [] [ trans InvitationText.NotFound ]
                        , p [] [ trans InvitationText.TryAgain ]
                        ]
                    ]
                
                _ -> []

        errorMessage =
            case focus.status of
                Error error ->
                    [ showError language error ] 

                Found invitation ->
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
                    , onlyOnSubmit address (CheckInvitation focus.key)
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


