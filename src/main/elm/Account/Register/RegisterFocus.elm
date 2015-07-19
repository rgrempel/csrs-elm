module Account.Register.RegisterFocus where

import Account.Register.RegisterTypes as RegisterTypes exposing (..)
import Account.Register.RegisterText as RegisterText

import Signal exposing (message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task, andThen, onError)
import Language.LanguageService exposing (Language)
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(Required, Email))
import List exposing (all, isEmpty)
import Account.AccountService as AccountService


hash2focus : List String -> Maybe Focus
hash2focus hashList = Just defaultFocus


focus2hash : Focus -> List String
focus2hash focus = []


reaction : Address RegisterTypes.Action -> RegisterTypes.Action -> Maybe (Task () ())
reaction address action =
    case action of
        SendInvitation email language ->
            if isEmpty (checkEmail email)
                then Just <|
                    AccountService.sendInvitationToCreateAccount email language
                    `andThen` (always (Signal.send address FocusInvitationSent))
                    `onError` (Signal.send address << FocusSendInvitationError)

                else
                    Nothing


        UseInvitation invitation ->
            if isEmpty (checkInvitation invitation)
                then
                    Nothing

                else
                    Nothing

        _ ->
            Nothing


updateFocus : RegisterTypes.Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    let
        focus' =
            withDefault defaultFocus focus
        
    in
        Just <|
            case action of
                FocusEmail email ->
                    @email email focus'

                FocusInvitation invitation ->
                    @invitation invitation focus'

                SendInvitation invitation language ->
                    @registerStatus SendingInvitation focus'
                   
                UseInvitation invitation ->
                    @registerStatus UsingInvitation focus'

                FocusInvitationSent ->
                    @registerStatus InvitationSent focus'

                _ -> focus'


defaultFocus : Focus
defaultFocus = Focus RegistrationStart "" ""


checkEmail : String -> List StringValidator
checkEmail = checkString [Required, Email]


checkInvitation : String -> List StringValidator
checkInvitation = checkString [Required]


renderFocus : Address RegisterTypes.Action -> Focus -> Language -> Html
renderFocus address focus language =
    let
        trans =
            RegisterText.translateHtml language

        wrap contents =
            div [ class "csrs-register container" ]
                [ div [ class "well well-sm" ]
                    [ div [ class "row" ]
                        [ div 
                            [ class "col-xs-12 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-6 col-lg-offset-3" ]
                            contents
                        ]
                    ]
                ]

        emailForm =
            let
                errors =
                    if focus.registerStatus == SendingInvitation
                        then checkEmail focus.email
                        else []

            in
                Html.form
                    [ role "form"
                    , onSubmit address (SendInvitation focus.email language)
                    ]
                    [ div
                        [ classList
                            [ ("form-group", True)
                            , ("has-error", not <| isEmpty errors)
                            ]
                        ]
                        <|
                        [ label 
                            [ for "email-input" ]
                            [ trans RegisterText.EmailAddress ]
                        , div [ class "input-group" ]
                            [ input 
                                [ id "email-input"
                                , type' "email"
                                , class "form-control"
                                , on "input" targetValue <| (message address) << FocusEmail
                                ] []
                            , span [ class "input-group-btn" ]
                                [ button 
                                    [ type' "submit"
                                    , class "btn btn-primary"
                                    ]
                                    [ glyphicon "send"
                                    , text unbreakableSpace
                                    , trans RegisterText.SendInvitation
                                    ]
                                ]
                            ]
                        ]
                        ++
                        (List.map (helpBlock language) errors)
                    ]
            
        invitationForm =
            let
                errors =
                    if focus.registerStatus == UsingInvitation
                        then checkInvitation focus.invitation
                        else []

            in
                Html.form
                    [ role "form"
                    , onSubmit address (UseInvitation focus.invitation)
                    ]
                    [ div
                        [ classList
                            [ ("form-group", True)
                            , ("has-error", not <| isEmpty errors)
                            ]
                        ]
                        <|
                        [ label
                            [ for "key-input" ]
                            [ trans RegisterText.InvitationKey ]
                        , div
                            [ class "input-group" ]
                            [ input
                                [ id "key-input"
                                , type' "text"
                                , class "form-control"
                                , on "input" targetValue <| (message address) << FocusInvitation
                                ] []
                            , span [ class "input-group-btn" ]
                                [ button
                                    [ type' "submit"
                                    , class "btn btn-primary"
                                    ]
                                    [ glyphicon "tag"
                                    , text unbreakableSpace
                                    , trans RegisterText.UseInvitation
                                    ]
                                ]
                            ]
                        ]
                        ++
                        ( List.map (helpBlock language) errors )
                    ]

        invitationSent =
            case focus.registerStatus of
                InvitationSent ->
                    div [ class "alert alert-success text-left" ]
                        [ h4 [] [ trans RegisterText.InvitationSent ]
                        , p [] [ trans RegisterText.InvitationMessage ]
                        ]

                _ ->
                    div [] []
 
    in
        wrap <|
            [ h2 [] [ trans RegisterText.CreateNewAccount ]
            , h3 [] [ trans RegisterText.RequestInvitation ]
            , p  [] [ trans RegisterText.CreateAccountBlurb ]
            
            , emailForm
            , invitationSent
            , p [] [ trans RegisterText.TryLogin ]
            , p [] [ trans RegisterText.PasswordReset ]

            , h3 [] [ trans RegisterText.UseInvitation ]
            , p [] [ trans RegisterText.InvitationBlurb ]
            , invitationForm 
            ]


renderMenuItem : Address RegisterTypes.Action -> Maybe Focus -> Language -> Html
renderMenuItem address focus language =
    li [ classList [ ( "active", focus /= Nothing ) ] ]
        [ a [ onClick address FocusBlank ]
            [ glyphicon "plus-sign" 
            , text unbreakableSpace
            , RegisterText.translateHtml language RegisterText.CreateNewAccount 
            ]
        ]

