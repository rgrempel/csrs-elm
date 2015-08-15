module Components.Account.Invitation.Register.RegisterFocus where

import AppTypes exposing (..)
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(..))
import Account.AccountServiceTypes as AccountServiceTypes exposing (UserEmailActivation, LoginError(..), CreateAccountError(..))
import Account.AccountService as AccountService
import Account.PasswordStrengthBar.PasswordStrengthBar as PasswordStrengthBar
import Route.RouteService exposing (PathAction(..))
import Components.FocusTypes as FocusTypes
import Components.Home.HomeTypes as HomeTypes
import Components.Account.Login.LoginText as LoginText

import Components.Account.Invitation.Register.RegisterTypes as RegisterTypes exposing (..)
import Components.Account.Invitation.Register.RegisterText as RegisterText

import Signal exposing (message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace, showError, onlyOnSubmit)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task, andThen, onError, mapError, sleep)
import Task.Util exposing (..)
import List exposing (all, isEmpty)
import Time exposing (Time, millisecond)
import Dict exposing (Dict)


-- You can't get here via hash ... 
route : List String -> Maybe Action
route hashList = Nothing


path : Maybe Focus -> Focus -> Maybe PathAction
path focus focus' = Nothing


-- This is the time for which the username field must be stable before
-- we contact the server to see whether it's taken or not.
debounceUserChecks : Time
debounceUserChecks = 500 * millisecond


reaction : Address RegisterTypes.Action -> RegisterTypes.Action -> Maybe Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        FocusUserName name ->
            -- The logic here is something like this. When we see that the
            -- username has changed, set a timeout so that after the debounce
            -- period, we'll possibly check the name. But, at that time, we'll
            -- check whether the username still matches ... if it's changed,
            -- we'll wait for the next timeout. This is imperfect, since the
            -- username may have changed and changed back to the previous value.
            -- But that's not a big deal.
            if name == "" then Nothing else Just <|
                sleep debounceUserChecks
                `andThen` always (Signal.send address (CheckUserName name))

        CheckUserName name ->
            focus `Maybe.andThen` \focus' ->
                if name /= focus'.accountInfo.username || Dict.member name focus'.users
                    then Nothing
                    else Just <|
                        (AccountService.userExists name
                        |> mapError (always ()))
                        `andThen` (Signal.send address << FocusUserExists name) 

        CreateAccount accountInfo activation language ->
            let
                goHome =
                    FocusTypes.do (FocusTypes.FocusHome HomeTypes.FocusHome)
                
                attemptLogin =
                    AccountService.attemptLogin
                        { username = accountInfo.username
                        , password = accountInfo.password
                        , rememberMe = False
                        }
                    `andThen` always goHome
                    `onError` notify address FocusLoginError

            in
                -- We bypass the check for existing users ... so we don't prevent submission
                -- So, the check for existing users is advisory only
                if isEmpty (checkAccountInfo Dict.empty accountInfo)
                    then
                        Just <|
                            AccountService.createAccount 
                                { username = accountInfo.username
                                , password = accountInfo.password
                                , language = language
                                , activationKey = activation.activationKey
                                }
                            `andThen` always attemptLogin
                            `onError` notify address FocusError 

                    else 
                        Nothing
        
        _ ->
            Nothing


update : RegisterTypes.Action -> Maybe Focus -> Maybe Focus
update action focus =
    let
        accountInfo =
            withDefault defaultAccountInfo <|
                Maybe.map .accountInfo focus

    in
        case (action, focus) of
            (FocusActivation activation, Nothing) ->
                Just <| defaultFocus activation

            (FocusActivation activation, Just focus') ->
                Just { focus' | activation <- activation }

            -- If there's no focus ... that is, we're coming from somewhere
            -- else -- then we don't accept the focus unless we were given
            -- an activation. That is, you have to start with an activation.
            (_, Nothing) ->
                Nothing

            (FocusPassword password, Just focus') ->
                Just
                    { focus' | accountInfo <- 
                        { accountInfo | password <- password }
                    }

            (FocusConfirmPassword password, Just focus') ->
                Just
                    { focus' | accountInfo <-
                        { accountInfo | confirmPassword <- password }
                    }

            (FocusUserName name, Just focus') ->
                Just
                    { focus' | accountInfo <-
                        { accountInfo | username <- name }
                    }
        
            (CreateAccount accountInfo activation language, Just focus') ->
                Just
                    { focus' | status <- CreatingAccount }

            (FocusError error, Just focus') ->
                Just
                    { focus' | status <- CreationError error }

            (FocusLoginError error, Just focus') ->
                Just
                    { focus' | status <- LoginError error }

            -- Note that if the focus has gone somewhere else, we
            -- don't drag it back here just because a task has
            -- completed. (Since we don't match a Nothing focus)
            (FocusUserExists user exists, Just focus') ->
                Just
                    { focus' | users <- Dict.insert user exists focus'.users }

            (_, Just focus') ->
                Just focus'


defaultFocus : UserEmailActivation -> Focus
defaultFocus = Focus RegisterStart defaultAccountInfo Dict.empty


defaultAccountInfo : AccountInfo
defaultAccountInfo = AccountInfo "" "" ""


checkUserName : Dict String Bool -> String -> List StringValidator
checkUserName dict = checkString [Required, NotTaken dict]


checkUserNameAvailable : Dict String Bool -> String -> List StringValidator
checkUserNameAvailable dict = checkString [NotTaken dict]


checkPassword : String -> List StringValidator
checkPassword = checkString [MinLength 5, MaxLength 50]


checkConfirmPassword : String -> String -> List StringValidator
checkConfirmPassword password = checkString [Matches password]


checkAccountInfo : Dict String Bool -> AccountInfo -> List StringValidator
checkAccountInfo dict accountInfo =
    checkUserName dict accountInfo.username ++
    checkPassword accountInfo.password ++
    checkConfirmPassword accountInfo.confirmPassword accountInfo.password


view : Address RegisterTypes.Action -> Model -> Focus -> Html
view address model focus =
    let
        language =
            model.useLanguage

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
                    case focus.status of
                        RegisterStart -> checkUserNameAvailable focus.users focus.accountInfo.username 
                        _ -> checkUserName focus.users focus.accountInfo.username

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
                            , id "username"
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
                , p [ class "form-control-static"
                    , id "email" 
                    ]
                    [ text focus.activation.userEmail.email.emailAddress ]
                ]

        passwordField =
            let
                errors =
                    case focus.status of
                        RegisterStart -> []
                        _ -> checkPassword focus.accountInfo.password

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
                            , id "password"
                            , type' "password"
                            , name "password"
                            , placeholder (trans RegisterText.PasswordPlaceholder)
                            , on "input" targetValue <| (message address) << FocusPassword
                            ] []
                        ]
                    , PasswordStrengthBar.draw language focus.accountInfo.password 
                    ]
                    ++ List.map (helpBlock language) errors

        confirmPasswordField =
            let
                errors =
                    case focus.status of
                        RegisterStart -> []
                        _ -> checkConfirmPassword focus.accountInfo.confirmPassword focus.accountInfo.password

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
                            , id "confirmPassword"
                            , name "confirmPassword"
                            , placeholder (trans RegisterText.ConfirmPasswordPlaceholder)
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
                 
                CreationError (UserAlreadyExists user) ->
                    p
                        [ class "alert alert-danger"
                        , id "loginFailed"
                        ]
                        [ transHtml <| RegisterText.UserAlreadyExists user ]

                CreationError (CreateAccountHttpError error) ->
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
                , onlyOnSubmit address (CreateAccount focus.accountInfo focus.activation model.useLanguage)
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
                        , id "submitButton"
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
            , result
            ]

