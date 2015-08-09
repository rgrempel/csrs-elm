module Components.Account.Invitation.ResetPassword.ResetPasswordFocus where

import AppTypes exposing (..)
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(..))
import Account.AccountServiceTypes as AccountServiceTypes exposing (UserEmailActivation)
import Account.PasswordStrengthBar.PasswordStrengthBar as PasswordStrengthBar
import Route.RouteService exposing (PathAction(..))

import Components.Account.Invitation.ResetPassword.ResetPasswordTypes as ResetPasswordTypes exposing (..)
import Components.Account.Invitation.ResetPassword.ResetPasswordText as ResetPasswordText

import Signal exposing (Address, message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace)
import Maybe exposing (withDefault)
import Task exposing (Task, andThen, onError)
import List exposing (all, isEmpty)


-- You can't get here via hash ... 
route : List String -> Maybe Action
route hashList = Nothing


path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' = Nothing


reaction : Address ResetPasswordTypes.Action -> ResetPasswordTypes.Action -> Maybe (Task () ())
reaction address action =
    case action of
        _ ->
            Nothing

{-
    this.resetPassword = function () {
        if (!$scope.resetPasswordForm.$valid) return;

        this.serverError = null;
        this.success = false;

        var self = this;
        $http.post('/api/reset_password', {
            key: this.invitation.activationKey,
            newPassword: this.password
        }).then(function () {
            Auth.login({
                username: self.login,
                password: self.password,
                rememberMe: false
            }).then(function () {
                $state.go('settings');
            }, function (error) {
                self.serverError = angular.toJson(error);
            });
        }, function (error) {
            self.serverError = angular.toJson(error);
        });
    };
});

-}


update : ResetPasswordTypes.Action -> Maybe Focus -> Maybe Focus
update action focus =
    case (action, focus) of
        (FocusActivation activation, Nothing) ->
            Just <| defaultFocus activation

        (_, Nothing) ->
            Nothing

        (FocusActivation activation, Just focus') ->
            Just <| {focus' | activation <- activation}

        (FocusStatus status, Just focus') ->
            Just <| {focus' | status <- status}

        (FocusPassword password, Just focus') ->
            Just <| {focus' | password <- password}

        (FocusConfirmPassword password, Just focus') ->
            Just <| {focus' | confirmPassword <- password}

        (_, Just focus') ->
            Just <| focus'


defaultFocus : UserEmailActivation -> Focus
defaultFocus = Focus Start "" "" ""


checkPassword : String -> List StringValidator
checkPassword = checkString [MinLength 5, MaxLength 50]


checkConfirmPassword : String -> String -> List StringValidator
checkConfirmPassword password = checkString [Matches password]


view : Address ResetPasswordTypes.Action -> Model -> Focus -> Html
view address model focus =
    let
        language =
            model.useLanguage

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
                , p [ class "form-control-static" ]
                    [ text <|
                        Maybe.withDefault "" <|
                            Maybe.map .username focus.activation.userEmail.user
                    ]
                ]

        emailField =
            div [ class "form-group" ]
                [ label []
                    [ transHtml ResetPasswordText.Email ]
                , p [ class "form-control-static" ]
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
                            , placeholder (trans ResetPasswordText.ConfirmPasswordPlaceholder)
                            , on "input" targetValue <| (message address) << FocusConfirmPassword
                            ] []
                        ]
                    ]
                    ++
                    List.map (helpBlock language) errors

        form =
            Html.form
                [ role "form"
                , class "form"
                -- , onSubmit address doSomething 
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
            ]

