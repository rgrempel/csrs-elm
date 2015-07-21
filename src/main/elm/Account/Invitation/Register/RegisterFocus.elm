module Account.Invitation.Register.RegisterFocus where

import Account.Invitation.Register.RegisterTypes as RegisterTypes exposing (..)
import Account.Invitation.Register.RegisterText as RegisterText

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
import Validation.ValidationTypes exposing (StringValidator, Validator(..))
import List exposing (all, isEmpty)
import Account.AccountService as AccountService exposing (UserEmailActivation)
import Focus.FocusTypes as FocusTypes
import Account.AccountTypes as AccountTypes
import Account.PasswordStrengthBar.PasswordStrengthBar as PasswordStrengthBar


-- You can't get here via hash ... 
hash2focus : List String -> Maybe Focus
hash2focus hashList = Nothing


focus2hash : Focus -> List String
focus2hash focus = []


reaction : Address RegisterTypes.Action -> RegisterTypes.Action -> Maybe (Task () ())
reaction address action =
    case action of
        _ ->
            Nothing

{-
    this.createAccount = function () {
        if (!$scope.createAccountForm.$valid) {return;}

        this.serverError = null;
        this.account.langKey = $translate.use();

        var self = this;
        Register.save({
            key: this.invitation.activationKey
        }, this.account, function () {
            Auth.login({
                username: self.account.login,
                password: self.account.password,
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
-}


updateFocus : RegisterTypes.Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    case (action, focus) of
        (FocusActivation activation, Nothing) ->
            Just <| defaultFocus activation

        (_, Nothing) ->
            Nothing

        (FocusActivation activation, Just focus') ->
            Just <| @activation activation focus'

        (FocusRegisterStatus status, Just focus') ->
            Just <| @registerStatus status focus'

        (FocusPassword password, Just focus') ->
            Just <| @password password focus'

        (FocusConfirmPassword password, Just focus') ->
            Just <| @confirmPassword password focus'

        (FocusUserName name, Just focus') ->
            Just <| @userName name focus'

        (_, Just focus') ->
            Just <| focus'


defaultFocus : UserEmailActivation -> Focus
defaultFocus = Focus RegisterStart "" "" ""


checkUserName : String -> List StringValidator
checkUserName = checkString [Required]


checkPassword : String -> List StringValidator
checkPassword = checkString [MinLength 5, MaxLength 50]


checkConfirmPassword : String -> String -> List StringValidator
checkConfirmPassword password = checkString [Matches password]


renderFocus : Address RegisterTypes.Action -> Focus -> Language -> Html
renderFocus address focus language =
    let
        trans =
            RegisterText.translateText language

        transHtml =
            RegisterText.translateHtml language
        
        wrap contents =
            div [ class "csrs-invitation-register container" ]
                [ div [ class "well well-sm" ]
                    [ div [ class "row" ]
                        [ div 
                            [ class "col-xs-12 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-6 col-lg-offset-3" ]
                            contents
                        ]
                    ]
                ]

        usernameField =
            let
                errors =
                    case focus.registerStatus of
                        RegisterStart -> []
                        _ -> checkUserName focus.userName

            in
                div
                    [ classList
                        [ ("form-group", True)
                        , ("has-error", not <| isEmpty errors)
                        ]
                    ]
                    <|
                    [ label []
                        [ transHtml RegisterText.UserName
                        , input 
                            [ class "form-control"
                            , type' "text"
                            , placeholder (trans RegisterText.UserNamePlaceholder)
                            , on "input" targetValue <| (message address) << FocusUserName
                            ] []
                        ]
                    ]
                    ++ List.map (helpBlock language) errors

        emailField =
            div [ class "form-group" ]
                [ label []
                    [ transHtml RegisterText.Email ]
                , p [ class "form-control-static" ]
                    [ text focus.activation.userEmail.email.emailAddress ]
                ]

        passwordField =
            let
                errors =
                    case focus.registerStatus of
                        RegisterStart -> []
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
                        [ transHtml RegisterText.NewPassword
                        , input
                            [ class "form-control"
                            , type' "password"
                            , name "password"
                            , placeholder (trans RegisterText.PasswordPlaceholder)
                            , on "input" targetValue <| (message address) << FocusPassword
                            ] []
                        ]
                    , PasswordStrengthBar.draw language focus.password 
                    ]
                    ++ List.map (helpBlock language) errors

        confirmPasswordField =
            let
                errors =
                    case focus.registerStatus of
                        RegisterStart -> []
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
                        [ transHtml RegisterText.ConfirmPassword
                        , input 
                            [ class "form-control"
                            , type' "password"
                            , name "confirmPassword"
                            , placeholder (trans RegisterText.ConfirmPasswordPlaceholder)
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
                        , transHtml RegisterText.Title
                        ]
                    ]
                ]
            ]
                 
    in
        wrap <|
            [ h2 [] [ transHtml RegisterText.Title ]
            , p [] [ transHtml RegisterText.Blurb ]
            , form
            ]

