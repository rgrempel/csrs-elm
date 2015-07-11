module Account.Login.LoginFocus where

import Account.Login.LoginTypes as LoginTypes exposing (..)

import Signal exposing (message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task)
import Language.LanguageService exposing (Language)
import Account.Login.LoginText as LoginText
import Account.AccountService as AccountService exposing (Credentials, Action(AttemptLogin), LoginResult(WrongPassword, Success))
import Focus.FocusTypes as FocusTypes
import Home.HomeTypes as HomeTypes


hash2focus : List String -> Maybe Focus
hash2focus hashList = Just defaultFocus


focus2hash : Focus -> List String
focus2hash focus = []


reaction : LoginTypes.Action -> Maybe (Task () ())
reaction action =
    case action of
        FocusLoginResult Success ->
            Just <|
                FocusTypes.do (FocusTypes.FocusHome HomeTypes.FocusHome) 

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

                FocusLoginResult loginResult ->
                    @loginResult (Just loginResult) focus'

                _ -> focus'


defaultFocus : Focus
defaultFocus =
    { credentials = blankCredentials
    , loginResult = Nothing
    }


blankCredentials : Credentials
blankCredentials =
    { username = ""
    , password = ""
    , rememberMe = False
    }


renderFocus : Address LoginTypes.Action -> Focus -> Language -> Html
renderFocus address focus language =
    let
        serviceAddress =
            .address AccountService.actions

        transHtml =
            LoginText.translateHtml language 
        
        trans =
            LoginText.translateText language

        usernameField =
            div [ key "username"
                , class "form-group"
                ]
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
       
        passwordField =
            div [ key "password"
                , class "form-group"
                ]
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
            case focus.loginResult of
                Just WrongPassword -> 
                    p
                        [ key "result"
                        , class "alert alert-danger" 
                        ]
                        [ transHtml LoginText.Failed ]

                Just Success ->
                    p 
                        [ key "result"
                        , class "alert alert-success"
                        ]
                        [ transHtml LoginText.Succeeded ]

                _ ->
                    div [ key "result" ] []

        loginForm =
            Html.form
                [ class "form"
                , onSubmit serviceAddress
                    <| AttemptLogin focus.credentials <| Just (address, FocusLoginResult)
                , role "form"
                ]
                [ usernameField
                , passwordField
                , rememberMeField
                , submitButton
                , result 
                ]
        
    in
        div [ class "csrs-auth-login container" ]
            [ div [ class "well well-sm" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-4 col-md-offset-4" ]
                        [ h1 [] [ transHtml LoginText.Title ]
                        , loginForm
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

