module View.Account.Login where

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)

import View.Account.Login.Language as LL
import Action exposing (Action)
import Model exposing (Model)


view : Signal.Address Action -> Model -> Html
view address model =
    let
        transHtml = LL.translateHtml model.useLanguage
        trans = LL.translate model.useLanguage

    in
        div [ class "csrs-auth-login container" ]
            [ div [ class "well well-sm" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-4 col-md-offset-4" ]
                        [ h1 [] [ transHtml LL.Title ]

                        , Html.form [ class "form" {-, role "form" -} ]
                            [ div [ class "form-group" ]
                                [ label [ for "username" ] [ transHtml LL.Username ]
                                , input
                                    [ class "form-control"
                                    , type' "text"
                                    , id "username"
                                    , placeholder <| trans LL.UsernamePlaceholder
                                    ] []
                                ]
                                    
                            , div [ class "form-group" ]
                                [ label [ for "password" ] [ transHtml LL.Password ]
                                , input
                                    [ class "form-control"
                                    , type' "password"
                                    , id "password"
                                    , placeholder <| trans LL.PasswordPlaceholder
                                    ] []
                                ]
                                    
                            , div [ class "form-group" ]
                                [ label []
                                    [ input
                                        [ type' "checkbox"
                                        , checked False
                                        ] []
                                    , text (" " ++ trans LL.RememberMe)
                                    ]
                                ]

                            , button
                                [ type' "submit"
                                , class "btn btn-primary"
                                ] [ transHtml LL.Button ]
                            ] 
                        ]
                    ]
                ]
            ]


{-
.csrs-auth-login
    .row
        .col-md-4.col-md-offset-4
            h1(translate="csrs.auth.login.title") Authentication

            .alert.alert-danger(
                ng-show="loginController.authenticationError"
                translate="csrs.auth.login.messages.error.authentication"
            ) <strong>Authentication failed!</strong> Please check your credentials and try again.
            
            form.form(
                role="form"
                name="loginForm"
            )
                .form-group
                    label(
                        for="username"
                        translate="csrs.auth.login.form.username"
                    ) Login
                    input.form-control(
                        type="text"
                        id="username"
                        placeholder="{{'csrs.auth.login.form.username.placeholder' | translate}}"
                        ng-model="loginController.username"
                    )
                        
                .form-group
                    label(
                        for="password"
                        translate="csrs.auth.login.form.password"
                    ) Password
                    input.form-control(
                        type="password"
                        id="password"
                        placeholder="{{'csrs.auth.login.form.password.placeholder' | translate}}"
                        ng-model="loginController.password"
                    )
                        
                .form-group
                    label
                        input(
                            type="checkbox"
                            ng-model="loginController.rememberMe"
                            checked
                        )
                        span(translate="csrs.auth.login.form.rememberme")
                
                button(
                    type="submit"
                    class="btn btn-primary"
                    ng-click="loginController.login()"
                    translate="csrs.auth.login.form.button"
                ) Authenticate
            
            p
                
            div.alert.alert-warning(translate="csrs.auth.login.messages.info.register")
                | Don't have an account yet? <a href="#!/register">Register a new account</a>
-}
