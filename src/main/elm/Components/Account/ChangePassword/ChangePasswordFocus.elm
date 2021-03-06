module Components.Account.ChangePassword.ChangePasswordFocus where

import AppTypes exposing (..)
import Account.AccountServiceTypes exposing (Credentials, LoginError(..))
import Account.AccountService as AccountService exposing (attemptLogin)
import Account.PasswordStrengthBar.PasswordStrengthBar as PasswordStrengthBar
import Validation.Validation exposing (checkString, helpBlock)
import Validation.ValidationTypes exposing (StringValidator, Validator(..))
import RouteHash exposing (HashUpdate)

import Components.Account.ChangePassword.ChangePasswordTypes as ChangePasswordTypes exposing (..)
import Components.Account.ChangePassword.ChangePasswordText as ChangePasswordText
import Components.Account.Login.LoginText as LoginText

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


reaction : Address Action -> Action -> Maybe Focus -> Maybe (Task () ())
reaction address action focus =
    case action of
        ChangePassword old new confirm ->
            if isEmpty (checkAllPasswords old new confirm)
                then
                    Just <|
                        dispatch
                            (AccountService.changePassword old new)
                            address FocusError (always FocusSuccess)
                
                else
                    Nothing

        _ ->
            Nothing


update : Action -> Maybe Focus -> Maybe Focus
update action focus =
    let
        focus' =
            withDefault defaultFocus focus
        
    in
        Just <|
            case action of
                FocusOldPassword password ->
                    { focus' | oldPassword <- password }

                FocusNewPassword password ->
                    { focus' | newPassword <- password }

                FocusConfirmPassword password ->
                    { focus' | confirmPassword <- password }

                FocusError error ->
                    { focus' | status <- Error error }

                ChangePassword old new confirm ->
                    { focus' | status <- ChangingPassword }

                FocusSuccess ->
                    { focus' | status <- Success }

                _ -> focus'


defaultFocus : Focus
defaultFocus = Focus "" "" "" Start 


checkPassword : String -> List StringValidator
checkPassword = checkString [MinLength 5, MaxLength 50]


checkConfirmPassword : String -> String -> List StringValidator
checkConfirmPassword password = checkString [Matches password]


checkAllPasswords : String -> String -> String -> List StringValidator
checkAllPasswords old new confirm =
    checkPassword old ++
    checkPassword new ++
    checkConfirmPassword new confirm


view : Address Action -> Model -> Focus -> Html
view address model focus =
    let
        language =
            model.language.useLanguage

        transHtml =
            ChangePasswordText.translateHtml language 
        
        trans =
            ChangePasswordText.translateText language

        oldPasswordField =
            let
                errors =
                    if focus.status == Start 
                        then []
                        else checkPassword focus.oldPassword

            in
                div
                    [ classList
                        [ ("form-group", True)
                        , ("has-error", not <| isEmpty errors)
                        ]
                    ]
                    <|
                    [ label [ for "oldPassword" ] [ transHtml ChangePasswordText.OldPassword ]
                    , input
                        [ class "form-control"
                        , type' "password"
                        , id "oldPassword"
                        , value focus.oldPassword
                        , placeholder <| trans ChangePasswordText.OldPasswordPlaceholder
                        , on "input" targetValue <| (message address) << FocusOldPassword
                        ] []
                    ]
                    ++ 
                    ( List.map (helpBlock language) errors )
                    ++
                    [ p 
                        [ class "help-block" ]
                        [ LoginText.translateHtml language LoginText.ResetPassword ]
                    ]

        newPasswordField =
            let
                errors =
                    if focus.status == Start 
                        then []
                        else checkPassword focus.newPassword

            in
                div
                    [ classList
                        [ ("form-group", True)
                        , ("has-error", not <| isEmpty errors)
                        ]
                    ]
                    <|
                    [ label [ for "newPassword" ] [ transHtml ChangePasswordText.NewPassword ]
                    , input
                        [ class "form-control"
                        , type' "password"
                        , id "newPassword"
                        , value focus.newPassword
                        , placeholder <| trans ChangePasswordText.NewPasswordPlaceholder
                        , on "input" targetValue <| (message address) << FocusNewPassword
                        ] []
                    , PasswordStrengthBar.draw language focus.newPassword 
                    ]
                    ++ 
                    ( List.map (helpBlock language) errors )

        confirmPasswordField =
            let
                errors =
                    if focus.status == Start 
                        then []
                        else checkConfirmPassword focus.confirmPassword focus.newPassword

            in
                div
                    [ classList
                        [ ("form-group", True)
                        , ("has-error", not <| isEmpty errors)
                        ]
                    ]
                    <|
                    [ label [ for "confirmPassword" ] [ transHtml ChangePasswordText.ConfirmPassword ]
                    , input
                        [ class "form-control"
                        , type' "password"
                        , id "confirmPassword"
                        , value focus.confirmPassword
                        , placeholder <| trans ChangePasswordText.ConfirmPasswordPlaceholder
                        , on "input" targetValue <| (message address) << FocusConfirmPassword
                        ] []
                    ]
                    ++ 
                    ( List.map (helpBlock language) errors )
 
        submitButton =
            button
                [ type' "submit"
                , id "submitButton"
                , class "btn btn-primary"
                ] [ transHtml ChangePasswordText.Title ]

        result =
            case focus.status of
                Error LoginWrongPassword -> 
                    p
                        [ class "alert alert-danger"
                        , id "loginFailed"
                        ]
                        [ transHtml ChangePasswordText.Failed ]
                
                Error (LoginHttpError error) ->
                    p
                        [ id "loginFailed"
                        ]
                        [ showError language error ]

                Success ->
                    strong 
                        [ class "alert alert-success"
                        , id "loginSuccess"
                        ]
                        [ transHtml ChangePasswordText.Success ]

                _ ->
                    p [] []

        changePasswordForm =
            Html.form
                [ class "form"
                , role "form"
                , onlyOnSubmit address (ChangePassword focus.oldPassword focus.newPassword focus.confirmPassword)
                ]
                [ div [ class "row" ]
                    [ div 
                        [ class "col-xs-6" ]
                        [ oldPasswordField ]
                    ]
                , div [ class "row" ]
                    [ div
                        [ class "col-xs-6" ]
                        [ newPasswordField ]
                    , div
                        [ class "col-xs-6" ]
                        [ confirmPasswordField ]
                    ]
                , div [ class "text-center" ] [ submitButton ]
                , div [ style [ ("margin-top", "18px") ]] [ result ] 
                ]
    
    in
        div [ class "csrs-auth-change-password container" ]
            [ div [ class "well well-sm" ]
                [ div [ class "row" ]
                    [ div [ class "col-xs-12 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-6 col-lg-offset-3" ]
                        [ h2
                            [] 
                            [ transHtml <|
                                ChangePasswordText.FullTitle <|
                                    withDefault "" <|
                                        Maybe.map .username model.account.currentUser
                            ]
                        , changePasswordForm
                        ]
                    ]
                ]
            ]


menuItem : Address Action -> Model -> Maybe Focus -> Maybe Html
menuItem address model focus =
    let
        menu =
            li [ classList [ ( "active", focus /= Nothing ) ] ]
                [ a [ onClick address FocusBlank
                    , id "navbar-account-change-password"
                    ]
                    [ glyphicon "lock" 
                    , text unbreakableSpace
                    , ChangePasswordText.translateHtml model.language.useLanguage ChangePasswordText.Title
                    ]
                ]
        in
            -- Only show menu item if we have a user logged in.
            Maybe.map (always menu) model.account.currentUser
