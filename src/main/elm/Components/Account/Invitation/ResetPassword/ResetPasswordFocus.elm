module Components.Account.Invitation.ResetPassword.ResetPasswordFocus where

import AppTypes exposing (..)
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(..))
import Account.AccountServiceTypes as AccountServiceTypes exposing (UserEmailActivation, LoginError(..))
import Account.AccountService as AccountService
import Account.PasswordStrengthBar.PasswordStrengthBar as PasswordStrengthBar
import Route.RouteService exposing (PathAction(..))
import Components.FocusTypes as FocusTypes
import Components.Home.HomeTypes as HomeTypes
import Components.Account.Login.LoginText as LoginText

import Components.Account.Invitation.ResetPassword.ResetPasswordTypes as ResetPasswordTypes exposing (..)
import Components.Account.Invitation.ResetPassword.ResetPasswordText as ResetPasswordText

import Signal exposing (Address, message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace, showError, onlyOnSubmit)
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


-- You can't get here via hash ... 
route : List String -> Maybe Action
route hashList = Nothing


path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' = Nothing


reaction : Address ResetPasswordTypes.Action -> ResetPasswordTypes.Action -> Maybe Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        ResetPassword password confirmPassword activation ->
            let
                goHome =
                    FocusTypes.do (FocusTypes.FocusHome HomeTypes.FocusHome)
                
                attemptLogin =
                    AccountService.attemptLogin
                        { username = withDefault "" <| Maybe.map .username activation.userEmail.user
                        , password = password
                        , rememberMe = False
                        }
                    `andThen` always goHome
                    `onError` notify address FocusLoginError

            in
                if isEmpty (checkPasswords password confirmPassword)
                    then
                        Just <|
                            AccountService.resetPassword password activation.activationKey
                            `andThen` always attemptLogin
                            `onError` notify address FocusError 

                    else 
                        Nothing
        _ ->
            Nothing


update : ResetPasswordTypes.Action -> Maybe Focus -> Maybe Focus
update action focus =
    case (action, focus) of
        (FocusActivation activation, Nothing) ->
            Just <| defaultFocus activation

        -- If there's no focus ... that is, we're coming from somewhere
        -- else ... and no activation, then we refuse to take the focus.
        -- In other words, you have to supply the activation first.
        (_, Nothing) ->
            Nothing

        (FocusActivation activation, Just focus') ->
            Just <| { focus' | activation <- activation }

        (FocusPassword password, Just focus') ->
            Just <| { focus' | password <- password }

        (FocusConfirmPassword password, Just focus') ->
            Just <| { focus' | confirmPassword <- password }

        (FocusError error, Just focus') ->
            Just { focus' | status <- Error error }

        (FocusLoginError error, Just focus') ->
            Just { focus' | status <- LoginError error }

        (ResetPassword password confirmPassword activation, Just focus') ->
            Just { focus' | status <- ResettingPassword }
        
        (_, Just focus') ->
            Just <| focus'


defaultFocus : UserEmailActivation -> Focus
defaultFocus = Focus Start "" ""


checkPasswords : String -> String -> List StringValidator
checkPasswords password confirmPassword =
    checkPassword password ++
    checkConfirmPassword password confirmPassword


checkPassword : String -> List StringValidator
checkPassword = checkString [MinLength 5, MaxLength 50]


checkConfirmPassword : String -> String -> List StringValidator
checkConfirmPassword password = checkString [Matches password]


view : Address ResetPasswordTypes.Action -> Model -> Focus -> Html
view address model focus =
    let
        language =
            model.language.useLanguage

        trans =
            ResetPasswordText.translateText language

        transHtml =
            ResetPasswordText.translateHtml language
        
        wrap contents =
            div [ class "csrs-invitation-reset-password container" ]
                [ div [ class "well well-sm" ]
                    [ div [ class "row" ]
                        [ div 
                            [ class "col-xs-12 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-6 col-lg-offset-3" ]
                            contents
                        ]
                    ]
                ]

        usernameField =
            div [ class "form-group" ]
                [ label []
                    [ transHtml ResetPasswordText.UserName ]
                , p [ class "form-control-static"
                    , id "username"
                    ]
                    [ text <|
                        Maybe.withDefault "" <|
                            Maybe.map .username focus.activation.userEmail.user
                    ]
                ]

        emailField =
            div [ class "form-group" ]
                [ label []
                    [ transHtml ResetPasswordText.Email ]
                , p [ class "form-control-static"
                    , id "email"
                    ]
                    [ text focus.activation.userEmail.email.emailAddress ]
                ]

        passwordField =
            let
                errors =
                    case focus.status of
                        Start -> []
                        _ -> checkPassword focus.password

            in
                div
                    [ classList
                        [ ("form-group", True)
                        , ("has-error", not <| isEmpty errors)
                        ]
                    ]
                    <|
                    [ label []
                        [ transHtml ResetPasswordText.NewPassword
                        , input
                            [ class "form-control"
                            , type' "password"
                            , name "password"
                            , id "password"
                            , placeholder (trans ResetPasswordText.PasswordPlaceholder)
                            , on "input" targetValue <| (message address) << FocusPassword
                            ] []
                        ]
                    , PasswordStrengthBar.draw language focus.password 
                    ]
                    ++ List.map (helpBlock language) errors

        confirmPasswordField =
            let
                errors =
                    case focus.status of
                        Start -> []
                        _ -> checkConfirmPassword focus.confirmPassword focus.password

            in
                div
                    [ classList
                        [ ("form-group", True)
                        , ("has-error", not <| isEmpty errors)
                        ]
                    ]
                    <|
                    [ label []
                        [ transHtml ResetPasswordText.ConfirmPassword
                        , input 
                            [ class "form-control"
                            , type' "password"
                            , name "confirmPassword"
                            , id "confirmPassword"
                            , placeholder (trans ResetPasswordText.ConfirmPasswordPlaceholder)
                            , on "input" targetValue <| (message address) << FocusConfirmPassword
                            ] []
                        ]
                    ]
                    ++
                    List.map (helpBlock language) errors

        result =
            case focus.status of
                LoginError LoginWrongPassword -> 
                    p
                        [ class "alert alert-danger"
                        , id "loginFailed"
                        ]
                        [ LoginText.translateHtml language LoginText.Failed ]
                
                LoginError (LoginHttpError error) ->
                    p
                        [ id "loginFailed"
                        ]
                        [ showError language error ]
                 
                Error error ->
                    p
                        [ id "loginFailed"
                        ]
                        [ showError language error ]
                
                _ ->
                    p [] []

        form =
            Html.form
                [ role "form"
                , class "form"
                , onlyOnSubmit address <| ResetPassword focus.password focus.confirmPassword focus.activation
                ]
                [ div [ class "row" ]
                    [ div
                        [ class "col-xs-6" ]
                        [ usernameField ]
                    , div 
                        [ class "col-xs-6" ]
                        [ emailField ]
                    ]
                , div [ class "row" ]
                    [ div
                        [ class "col-xs-6" ]
                        [ passwordField ]
                    , div
                        [ class "col-xs-6" ]
                        [ confirmPasswordField ]
                , div [ class "row text-center" ]
                    [ button
                        [ type' "submit"
                        , class "btn btn-primary"
                        , id "submitButton"
                        ]
                        [ glyphicon "send"
                        , text unbreakableSpace
                        , transHtml ResetPasswordText.Title
                        ]
                    ]
                ]
            ]
                 
    in
        wrap <|
            [ h2 [] [ transHtml ResetPasswordText.Title ]
            , form
            , result
            ]

