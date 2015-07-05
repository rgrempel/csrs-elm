module Account.Login.LoginFocus where

import Signal exposing (message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace)
import Signal exposing (Address)
import Maybe exposing (withDefault)

import Language.LanguageService exposing (Language)

import Account.Login.LoginText as LoginText
import Account.AccountService as AccountService exposing (Credentials, Action(AttemptLogin))

type Action
    = FocusUserName String
    | FocusPassword String
    | FocusRememberMe Bool
    | FocusBlank

type alias Focus = Credentials


hash2focus : List String -> Maybe Focus
hash2focus hashList = Just blankCredentials


focus2hash : Focus -> List String
focus2hash focus = []


updateFocus : Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    let
        focus' = withDefault blankCredentials focus

    in
        Just <|
            case action of
                FocusUserName name ->
                    { focus' | username <- name }

                FocusPassword password ->
                    { focus' | password <- password }

                FocusRememberMe rememberMe ->
                    { focus' | rememberMe <- rememberMe }

                _ -> focus'


blankCredentials : Credentials
blankCredentials =
    { username = ""
    , password = ""
    , rememberMe = False
    }


renderFocus : Address Action -> Focus -> Language -> Html
renderFocus address focus language =
    let
        serviceAddress =
            .address AccountService.service

        transHtml =
            LoginText.translateHtml language 
        
        trans =
            LoginText.translateText language

        usernameField =
            div [ class "form-group" ]
                [ label [ for "username" ] [ transHtml LoginText.Username ]
                , input
                    [ class "form-control"
                    , type' "text"
                    , id "username"
                    , placeholder <| trans LoginText.UsernamePlaceholder
                    , value focus.username
                    , on "input" targetValue <| (message address) << FocusUserName
                    ] []
                ]
       
        passwordField =
            div [ class "form-group" ]
                [ label [ for "password" ] [ transHtml LoginText.Password ]
                , input
                    [ class "form-control"
                    , type' "password"
                    , id "password"
                    , value focus.password
                    , placeholder <| trans LoginText.PasswordPlaceholder
                    , on "input" targetValue <| (message address) << FocusPassword
                    ] []
                ]
                 
        rememberMeField =
            div [ class "form-group" ]
                [ label []
                    [ input
                        [ type' "checkbox"
                        , checked focus.rememberMe
                        , on "input" targetChecked <| (message address) << FocusRememberMe
                        ] []
                    , text " "
                    , transHtml LoginText.RememberMe
                    ]
                ]

        submitButton =
            button
                [ type' "submit"
                , class "btn btn-primary"
                ] [ transHtml LoginText.Button ]

        loginForm =
            Html.form
                [ class "form"
                , onSubmit serviceAddress ( AttemptLogin focus ) 
                , role "form"
                ]
                [ usernameField
                , passwordField
                , rememberMeField
                , submitButton
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


renderMenuItem : Address Action -> Maybe Focus -> Language -> Html
renderMenuItem address focus language =
    li [ classList [ ( "active", focus /= Nothing ) ] ]
        [ a [ onClick address FocusBlank ]
            [ glyphicon "log-in" 
            , text unbreakableSpace
            , LoginText.translateHtml language LoginText.Title 
            ]
        ]

