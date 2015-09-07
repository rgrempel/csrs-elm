module Components.Account.ResetPassword.ResetPasswordFocus where

import AppTypes exposing (..)
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(Required, Email))
import Account.AccountService as AccountService
import Route.RouteService exposing (PathAction(..))

import Components.Account.ResetPassword.ResetPasswordTypes as ResetPasswordTypes exposing (..)
import Components.Account.ResetPassword.ResetPasswordText as ResetPasswordText
import Components.FocusTypes as FocusTypes
import Components.Account.AccountTypes as AccountTypes
import Components.Account.Invitation.InvitationTypes as InvitationTypes

import Signal exposing (Address, message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit, on, targetValue)
import Html.Util exposing (role, glyphicon, unbreakableSpace, onlyOnSubmit)
import Maybe exposing (withDefault)
import Task exposing (Task, andThen, onError)
import Task.Util exposing (..)
import List exposing (all, isEmpty)


subcomponent : SubComponent Action Focus 
subcomponent =
    { route = route
    , path = path
    , reaction = Just reaction
    , update = update
    , view = view
    , menu = Nothing 
    }


route : List String -> Maybe Action
route hashList = Just FocusBlank


-- If we came from elsewhere ... i.e. focus was nothing ...
-- then set the path, otherwise not
path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' =
    if focus == Nothing
        then Just <| SetPath []
        else Nothing


reaction : Address ResetPasswordTypes.Action -> ResetPasswordTypes.Action -> Maybe ResetPasswordTypes.Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        SendToken email language ->
            if isEmpty (checkEmail email)
                then Just <|
                    dispatch
                        (AccountService.sendInvitationToResetPassword email language)
                        address FocusSendTokenError (always FocusTokenSent)

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


update : ResetPasswordTypes.Action -> Maybe Focus -> Maybe Focus
update action focus =
    let
        focus' =
            withDefault defaultFocus focus
        
    in
        Just <|
            case action of
                FocusEmail email ->
                    {focus' | email <- email}

                FocusToken token ->
                    {focus' | token <- token}

                SendToken token language ->
                    {focus' | status <- Sending}

                UseToken token ->
                    {focus' | status <- Using}

                FocusTokenSent ->
                    {focus' | status <- Sent}

                FocusSendTokenError error ->
                    {focus' | status <- ErrorSending error}

                _ -> focus'


defaultFocus : Focus
defaultFocus = Focus Start "" ""


checkEmail : String -> List StringValidator
checkEmail = checkString [Required, Email]


checkToken : String -> List StringValidator
checkToken = checkString [Required]


view : Address ResetPasswordTypes.Action -> Model -> Focus -> Html
view address model focus =
    let
        trans =
            ResetPasswordText.translateHtml model.language.useLanguage

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
                    if focus.status == Using
                        then checkToken focus.token
                        else []

            in
                Html.form
                    [ role "form"
                    , class "form"
                    , onlyOnSubmit address (UseToken focus.token)
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
                                    , id "key-submit"
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
                        ( List.map (helpBlock model.language.useLanguage) errors )
                    ]

        emailForm =
            let
                errors =
                    if focus.status == Sending
                        then checkEmail focus.email
                        else []

            in
                Html.form
                    [ role "form"
                    , class "form"
                    , onlyOnSubmit address (SendToken focus.email model.language.useLanguage)
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
                                    , id "email-submit"
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
                        ( List.map (helpBlock model.language.useLanguage) errors )
                    ]

        tokenSent =
            case focus.status of
                Sent ->
                    div [ class "alert alert-success text-left" 
                        , id "invitation-sent"
                        ]
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


