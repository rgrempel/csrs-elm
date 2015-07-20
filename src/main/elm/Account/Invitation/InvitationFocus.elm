module Account.Invitation.InvitationFocus where

import Account.Invitation.InvitationTypes as InvitationTypes exposing (..)
import Account.Invitation.InvitationText as InvitationText

import Signal exposing (message)
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
            Just <| @key first defaultFocus

        _ ->
            Just defaultFocus


focus2hash : Focus -> List String
focus2hash focus =
    case focus.key of
        "" -> []
        other -> [other]
            

reaction : Address InvitationTypes.Action -> InvitationTypes.Action -> Maybe (Task () ())
reaction address action =
    case action of
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
        focus' =
            withDefault defaultFocus focus
        
    in
        Just <|
            case action of
                FocusKey key ->
                    @key key focus'

                CheckInvitation key ->
                    @invitationStatus CheckingInvitation focus'

                FocusInvitationNotFound ->
                    @invitationStatus InvitationNotFound focus'

                FocusInvitationFound activation ->
                    @invitationStatus (InvitationFound activation) focus'

                FocusError error ->
                    @invitationStatus (Error error) focus'
    
                _ -> focus'


defaultFocus : Focus
defaultFocus = Focus InvitationStart "" 


checkRequired : String -> List StringValidator
checkRequired = checkString [Required]


renderFocus : Address InvitationTypes.Action -> Focus -> Language -> Html
renderFocus address focus language =
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
            case focus.invitationStatus of
                InvitationStart -> []
                _ -> checkRequired focus.key

        failureMessage =
            case focus.invitationStatus of
                InvitationNotFound ->
                    [ div [ class "alert alert-danger text-left" ]
                        [ h4 [] [ trans InvitationText.NotFound ]
                        , p [] [ trans InvitationText.TryAgain ]
                        ]
                    ]
                
                _ -> []

        errorMessage =
            case focus.invitationStatus of
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

