module Components.Account.Login.LoginFocus where

import AppTypes exposing (..)
import Account.AccountServiceTypes exposing (Credentials, LoginError(..))
import Account.AccountService as AccountService exposing (attemptLogin)
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(Required))
import RouteHash exposing (HashUpdate)

import Components.Account.Login.LoginTypes as LoginTypes exposing (..)
import Components.Account.Login.LoginText as LoginText
import Components.FocusTypes as FocusTypes
import Components.Home.HomeTypes as HomeTypes

import Signal exposing (message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace, showError, onlyOnSubmit)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task)
import Task.Util exposing (..)
import List exposing (all, isEmpty)


subcomponent : SubComponent Action Focus 
subcomponent =
    { route = route
    , path = path
    , reaction = Just reaction
    , update = update
    , view = view
    , menu = Just menuItem 
    }


route : List String -> Maybe Action
route hashList = Just FocusBlank


path : Maybe Focus -> Focus -> Maybe HashUpdate
path focus focus' =
    if focus == Nothing
        then Just <| RouteHash.set []
        else Nothing


reaction : Address LoginTypes.Action -> LoginTypes.Action -> Maybe Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        AttemptLogin credentials ->
            if checkCredentials credentials
                then
                    Just <|
                        AccountService.attemptLogin credentials
                        `Task.andThen` always (FocusTypes.do (FocusTypes.FocusHome HomeTypes.FocusHome))
                        `Task.onError` notify address FocusLoginError
                
                else
                    Nothing

        _ ->
            Nothing


update : LoginTypes.Action -> Maybe Focus -> Maybe Focus
update action focus =
    let
        focus' =
            withDefault defaultFocus focus
        
        updateCredentials value =
            {focus' | credentials <- value}

        credentials =
            focus'.credentials

    in
        Just <|
            case action of
                FocusUserName name ->
                    updateCredentials {credentials | username <- name}

                FocusPassword password ->
                    updateCredentials {credentials | password <- password}

                FocusRememberMe rememberMe ->
                    updateCredentials {credentials | rememberMe <- rememberMe}

                FocusLoginError loginError ->
                    {focus' | status <- Error loginError}

                AttemptLogin credentials ->
                    {focus' | status <- LoggingIn}

                _ -> focus'


defaultFocus : Focus
defaultFocus = Focus blankCredentials Start


blankCredentials : Credentials
blankCredentials = Credentials "" "" False


checkCredentials : Credentials -> Bool
checkCredentials credentials =
    List.all (isEmpty << checkRequired)
        [ credentials.username
        , credentials.password
        ]


checkRequired : String -> List StringValidator
checkRequired = checkString [Required]
    

view : Address LoginTypes.Action -> Model -> Focus -> Html
view address model focus =
    let
        language =
            model.language.useLanguage

        transHtml =
            LoginText.translateHtml language 
        
        trans =
            LoginText.translateText language

        usernameField =
            let
                errors =
                    if focus.status == Start
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
                    if focus.status == Start
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
                        , id "rememberMe"
                        , on "change" targetChecked <| (message address) << FocusRememberMe
                        ] []
                    , text " "
                    , transHtml LoginText.RememberMe
                    ]
                ]

        submitButton =
            button
                [ type' "submit"
                , key "submit"
                , id "submitButton"
                , class "btn btn-primary"
                ] [ transHtml LoginText.Button ]

        result =
            case focus.status of
                Error LoginWrongPassword -> 
                    p
                        [ key "result"
                        , class "alert alert-danger"
                        , id "loginFailed"
                        ]
                        [ transHtml LoginText.Failed ]
                
                Error (LoginHttpError error) ->
                    p
                        [ key "result"
                        , id "loginFailed"
                        ]
                        [ showError language error ]

                LoggedIn ->
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
                , onlyOnSubmit address (AttemptLogin focus.credentials)
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


menuItem : Address LoginTypes.Action -> Model -> Maybe Focus -> Maybe Html
menuItem address model focus =
    let
        menu =
            li [ classList [ ( "active", focus /= Nothing ) ] ]
                [ a [ onClick address FocusBlank
                    , id "navbar-account-login"
                    ]
                    [ glyphicon "log-in" 
                    , text unbreakableSpace
                    , LoginText.translateHtml model.language.useLanguage LoginText.Title 
                    ]
                ]

    in
        if model.account.currentUser == Nothing
            then Just menu
            else Nothing
