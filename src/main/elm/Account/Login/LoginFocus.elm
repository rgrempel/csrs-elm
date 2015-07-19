module Account.Login.LoginFocus where

import Account.Login.LoginTypes as LoginTypes exposing (..)
import Account.Login.LoginText as LoginText

import Signal exposing (message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task)
import Language.LanguageService exposing (Language)
import Account.AccountService as AccountService exposing (Credentials, attemptLogin)
import Focus.FocusTypes as FocusTypes
import Home.HomeTypes as HomeTypes
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(Required))
import List exposing (all, isEmpty)


hash2focus : List String -> Maybe Focus
hash2focus hashList = Just defaultFocus


focus2hash : Focus -> List String
focus2hash focus = []


reaction : Address LoginTypes.Action -> LoginTypes.Action -> Maybe (Task () ())
reaction address action =
    case action of
        AttemptLogin credentials ->
            if checkCredentials credentials
                then
                    Just <|
                        (AccountService.attemptLogin credentials)
                        `Task.andThen` (\user -> 
                            FocusTypes.do (FocusTypes.FocusHome HomeTypes.FocusHome)
                        ) `Task.onError` (\error ->
                            Signal.send address (FocusLoginError error)
                        )
                else
                    Nothing

        _ ->
            Nothing


updateFocus : LoginTypes.Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    let
        focus' =
            withDefault defaultFocus focus
        
        updateCredentials func value =
            @credentials (func value focus'.credentials) focus'

    in
        Just <|
            case action of
                FocusUserName name ->
                    updateCredentials @username name

                FocusPassword password ->
                    updateCredentials @password password

                FocusRememberMe rememberMe ->
                    updateCredentials @rememberMe rememberMe

                FocusLoginError loginError ->
                    @loginStatus (LoginError loginError) focus'

                AttemptLogin credentials ->
                    @loginStatus LoginInProgress focus'

                _ -> focus'


defaultFocus : Focus
defaultFocus =
    { credentials = blankCredentials
    , loginStatus = LoginNotAttempted
    }


blankCredentials : Credentials
blankCredentials =
    { username = ""
    , password = ""
    , rememberMe = False
    }


checkCredentials : Credentials -> Bool
checkCredentials credentials =
    List.all (isEmpty << checkRequired)
        [ credentials.username
        , credentials.password
        ]


checkRequired : String -> List StringValidator
checkRequired = checkString [Required]
    

renderFocus : Address LoginTypes.Action -> Focus -> Language -> Html
renderFocus address focus language =
    let
        transHtml =
            LoginText.translateHtml language 
        
        trans =
            LoginText.translateText language

        usernameField =
            let
                errors =
                    if focus.loginStatus == LoginNotAttempted
                        then []
                        else checkRequired focus.credentials.username

            in
                div [ key "username"
                    , classList
                        [ ("form-group", True)
                        , ("has-error", not <| isEmpty errors)
                        ]
                    ]
                    <|
                    [ label [ for "username" ] [ transHtml LoginText.Username ]
                    , input
                        [ class "form-control"
                        , type' "text"
                        , id "username"
                        , placeholder <| trans LoginText.UsernamePlaceholder
                        , value focus.credentials.username
                        , on "input" targetValue <| (message address) << FocusUserName
                        ] [] 
                    ]
                    ++ 
                    ( List.map (helpBlock language) errors )
 
        passwordField =
            let
                errors =
                    if focus.loginStatus == LoginNotAttempted
                        then []
                        else checkRequired focus.credentials.password

            in
                div [ key "password"
                    , classList
                        [ ("form-group", True)
                        , ("has-error", not <| isEmpty errors)
                        ]
                    ]
                    <|
                    [ label [ for "password" ] [ transHtml LoginText.Password ]
                    , input
                        [ class "form-control"
                        , type' "password"
                        , id "password"
                        , value focus.credentials.password
                        , placeholder <| trans LoginText.PasswordPlaceholder
                        , on "input" targetValue <| (message address) << FocusPassword
                        ] []
                    ]
                    ++ 
                    ( List.map (helpBlock language) errors )
 
        rememberMeField =
            div [ key "rememberMe"
                , class "form-group"
                ]
                [ label []
                    [ input
                        [ type' "checkbox"
                        , checked focus.credentials.rememberMe
                        , on "input" targetChecked <| (message address) << FocusRememberMe
                        ] []
                    , text " "
                    , transHtml LoginText.RememberMe
                    ]
                ]

        submitButton =
            button
                [ type' "submit"
                , key "submit"
                , class "btn btn-primary"
                ] [ transHtml LoginText.Button ]

        result =
            case focus.loginStatus of
                LoginError loginError -> 
                    p
                        [ key "result"
                        , class "alert alert-danger" 
                        ]
                        [ transHtml LoginText.Failed ]

                LoginSuccess ->
                    p 
                        [ key "result"
                        , class "alert alert-success"
                        ]
                        [ transHtml LoginText.Succeeded ]

                _ ->
                    p [ key "result" ] []

        loginForm =
            Html.form
                [ class "form"
                , role "form"
                , onSubmit address (AttemptLogin focus.credentials)
                ]
                [ usernameField
                , passwordField
                , rememberMeField
                , div [ class "text-center" ] [ submitButton ]
                , div [ style [ ("margin-top", "18px") ]] [ result ] 
                ]
        
    in
        div [ class "csrs-auth-login container" ]
            [ div [ class "well well-sm" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-4 col-md-offset-4" ]
                        [ h1 [] [ transHtml LoginText.Title ]
                        , loginForm
                        , div 
                            [ class "alert alert-warning"
                            , style [ ("margin-top", "18px") ]
                            ] 
                            [ transHtml LoginText.Register ]
                        , div
                            [ class "alert alert-warning" ]
                            [ transHtml LoginText.ResetPassword ]
                        ]
                    ]
                ]
            ]


renderMenuItem : Address LoginTypes.Action -> Maybe Focus -> Language -> Html
renderMenuItem address focus language =
    li [ classList [ ( "active", focus /= Nothing ) ] ]
        [ a [ onClick address FocusBlank ]
            [ glyphicon "log-in" 
            , text unbreakableSpace
            , LoginText.translateHtml language LoginText.Title 
            ]
        ]

