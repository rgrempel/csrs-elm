module Account.Login.View where

import Html exposing (..)
import Html.Events exposing (onClick, onSubmit, on, targetValue, targetChecked)
import Html.Attributes exposing (..)

import Account.Login.Language as LL
import Account.Login.Model exposing (Credentials)
import Types exposing (Action(SwitchFocus, AttemptLogin), Model)
import Focus.Types exposing (Focus(Account), AccountFocus(Login))
import Model exposing (extractCredentials)


view : Signal.Address Action -> Credentials -> Model -> Html
view address credentials model =
    let
        transHtml =
            LL.translateHtml model.useLanguage
        
        trans =
            LL.translate model.useLanguage
        
        updateUserName name =
            Signal.message address <|
                SwitchFocus ( Account ( Login { credentials | username <- name } ) )

        updatePassword password =
            Signal.message address <|
                SwitchFocus ( Account ( Login { credentials | password <- password } ) )
        
        updateRememberMe remember =
            Signal.message address <|
                SwitchFocus ( Account ( Login { credentials | rememberMe <- remember } ) )

    in
        div [ class "csrs-auth-login container" ]
            [ div [ class "well well-sm" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-4 col-md-offset-4" ]
                        [ h1 [] [ transHtml LL.Title ]

                        , Html.form
                            [ class "form"
                            , onSubmit address ( AttemptLogin credentials ) 
                            {-, role "form" -}
                            ]
                            [ div [ class "form-group" ]
                                [ label [ for "username" ] [ transHtml LL.Username ]
                                , input
                                    [ class "form-control"
                                    , type' "text"
                                    , id "username"
                                    , placeholder <| trans LL.UsernamePlaceholder
                                    , value (extractCredentials model).username
                                    , on "input" targetValue updateUserName 
                                    ] []
                                ]
                                    
                            , div [ class "form-group" ]
                                [ label [ for "password" ] [ transHtml LL.Password ]
                                , input
                                    [ class "form-control"
                                    , type' "password"
                                    , id "password"
                                    , value (extractCredentials model).password
                                    , placeholder <| trans LL.PasswordPlaceholder
                                    , on "input" targetValue updatePassword
                                    ] []
                                ]
                                    
                            , div [ class "form-group" ]
                                [ label []
                                    [ input
                                        [ type' "checkbox"
                                        , checked (extractCredentials model).rememberMe
                                        , on "input" targetChecked updateRememberMe
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
