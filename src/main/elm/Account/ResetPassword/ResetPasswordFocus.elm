module Account.ResetPassword.ResetPasswordFocus where

import Account.ResetPassword.ResetPasswordTypes as ResetPasswordTypes exposing (..)
import Account.ResetPassword.ResetPasswordText as ResetPasswordText

import Signal exposing (message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit, on, targetValue)
import Html.Util exposing (role, glyphicon, unbreakableSpace)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task, andThen, onError)
import Language.LanguageService exposing (Language)
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(Required, Email))
import List exposing (all, isEmpty)
import Account.AccountService as AccountService
import Focus.FocusTypes as FocusTypes
import Account.AccountTypes as AccountTypes
import Account.Invitation.InvitationTypes as InvitationTypes


hash2focus : List String -> Maybe Focus
hash2focus hashList = Just defaultFocus


focus2hash : Focus -> List String
focus2hash focus = []


reaction : Address ResetPasswordTypes.Action -> ResetPasswordTypes.Action -> Maybe (Task () ())
reaction address action =
    case action of
        SendToken email language ->
            if isEmpty (checkEmail email)
                then Just <|
                    AccountService.sendInvitationToResetPassword email language
                    `andThen` (always (Signal.send address FocusTokenSent))
                    `onError` (Signal.send address << FocusSendTokenError)

                else
                    Nothing


        UseToken token ->
            let
                do =
                    FocusTypes.do <<
                        FocusTypes.FocusAccount <<
                            AccountTypes.FocusInvitation
            
            in
                if isEmpty (checkToken token)
                    then
                        Just <|
                            (do <| InvitationTypes.FocusKey token)
                            `andThen`
                            (always <| do <| InvitationTypes.CheckInvitation token)

                    else
                        Nothing

        _ ->
            Nothing


updateFocus : ResetPasswordTypes.Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    let
        focus' =
            withDefault defaultFocus focus
        
    in
        Just <|
            case action of
                FocusEmail email ->
                    @email email focus'

                FocusToken token ->
                    @token token focus'

                SendToken token language ->
                    @resetPasswordStatus SendingToken focus'

                UseToken token ->
                    @resetPasswordStatus UsingToken focus'

                FocusTokenSent ->
                    @resetPasswordStatus TokenSent focus'

                _ -> focus'


defaultFocus : Focus
defaultFocus = Focus ResetPasswordStart "" ""


checkEmail : String -> List StringValidator
checkEmail = checkString [Required, Email]


checkToken : String -> List StringValidator
checkToken = checkString [Required]


renderFocus : Address ResetPasswordTypes.Action -> Focus -> Language -> Html
renderFocus address focus language =
    let
        trans =
            ResetPasswordText.translateHtml language

        wrap contents =
            div [ class "csrs-resetPassword container" ]
                [ div [ class "well well-sm" ]
                    [ div [ class "row" ]
                        [ div 
                            [ class "col-xs-12 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-6 col-lg-offset-3" ]
                            contents
                        ]
                    ]
                ]

        tokenForm =
            let
                errors =
                    if focus.resetPasswordStatus == UsingToken
                        then checkToken focus.token
                        else []

            in
                Html.form
                    [ role "form"
                    , class "form"
                    , onSubmit address (UseToken focus.token)
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
                            [ trans ResetPasswordText.Token ]
                        , div
                            [ class "input-group" ]
                            [ input
                                [ id "key-input"
                                , type' "text"
                                , class "form-control"
                                , on "input" targetValue <| (message address) << FocusToken
                                ] []
                            , span [ class "input-group-btn" ]
                                [ button
                                    [ type' "submit"
                                    , class "btn btn-primary"
                                    ]
                                    [ glyphicon "tag"
                                    , text unbreakableSpace
                                    , trans ResetPasswordText.UseToken
                                    ]
                                ]
                            ]
                        ]
                        ++
                        ( List.map (helpBlock language) errors )
                    ]

        emailForm =
            let
                errors =
                    if focus.resetPasswordStatus == SendingToken
                        then checkEmail focus.email
                        else []

            in
                Html.form
                    [ role "form"
                    , class "form"
                    , onSubmit address (SendToken focus.email language)
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
                            [ trans ResetPasswordText.EmailAddress ]
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
                                    , trans ResetPasswordText.SendToken
                                    ]
                                ]
                            ]
                        ]
                        ++
                        ( List.map (helpBlock language) errors )
                    ]

        tokenSent =
            case focus.resetPasswordStatus of
                TokenSent ->
                    div [ class "alert alert-success text-left" ]
                        [ h4 [] [ trans ResetPasswordText.TokenSent ]
                        , p [] [ trans ResetPasswordText.TokenMessage ]
                        ]

                _ ->
                    div [] []
 
    in
        wrap <|
            [ h2 [] [ trans ResetPasswordText.Title ]
            , h3 [] [ trans ResetPasswordText.SendToken ]
            , p  [] [ trans ResetPasswordText.Blurb ]
            , emailForm
            , tokenSent
            , p [] [ trans ResetPasswordText.CreateAccount ] 
            , h3 [] [ trans ResetPasswordText.UseToken ]
            , p [] [ trans ResetPasswordText.UseTokenBlurb ]
            , tokenForm            
            ]


