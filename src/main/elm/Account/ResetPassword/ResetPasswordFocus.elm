module Account.ResetPassword.ResetPasswordFocus where

import Account.ResetPassword.ResetPasswordTypes as ResetPasswordTypes exposing (..)
import Account.ResetPassword.ResetPasswordText as ResetPasswordText

import Signal exposing (message)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Util exposing (role, glyphicon, unbreakableSpace)
import Signal exposing (Address)
import Maybe exposing (withDefault)
import Task exposing (Task)
import Language.LanguageService exposing (Language)


hash2focus : List String -> Maybe Focus
hash2focus hashList = Just defaultFocus


focus2hash : Focus -> List String
focus2hash focus = []


reaction : Address ResetPasswordTypes.Action -> ResetPasswordTypes.Action -> Maybe (Task () ())
reaction address action =
    case action of
        _ ->
            Nothing


updateFocus : ResetPasswordTypes.Action -> Maybe Focus -> Maybe Focus
updateFocus action focus =
    let
        focus' =
            withDefault defaultFocus focus
        
    in
        Just <|
            case action of
                _ -> focus'


defaultFocus : Focus
defaultFocus = Focus ResetPasswordNotAttempted


renderFocus : Address ResetPasswordTypes.Action -> Focus -> Language -> Html
renderFocus address focus language =
    let
        trans =
            ResetPasswordText.translateHtml language

        wrap contents =
            div [ class "csrs-resetPassword container" ]
                [ div [ class "well well-sm" ]
                    [ div [ class "row" ]
                        [ div 
                            [ class "col-xs-12 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-6 col-lg-offset-3" ]
                            contents
                        ]
                    ]
                ]

        tokenForm =
            Html.form [ role "form" ]
                [ div [ class "form-group" ]
                    [ label [ for "key-input" ]
                        [ trans ResetPasswordText.Token ]
                    , div [ class "input-group" ]
                        [ input
                            [ id "key-input"
                            , type' "text"
                            , class "form-control"
                            ] []
                        , span [ class "input-group-btn" ]
                            [ button
                                [ type' "button"
                                , class "btn btn-primary"
                                ]
                                [ glyphicon "tag"
                                , text unbreakableSpace
                                , trans ResetPasswordText.UseToken
                                ]
                            ]
                        ]
                    , p [ class "help-block" ] [ text "Required" ]
                    ]
                ]

        emailForm =
            Html.form [ role "form" ]
                [ div [ class "form-group" ]
                    [ label [ for "email-input" ]
                            [ trans ResetPasswordText.EmailAddress ]
                    , div [ class "input-group" ]
                        [ input 
                            [ id "email-input"
                            , type' "email"
                            , class "form-control"
                            ] []
                        , span [ class "input-group-btn" ]
                            [ button 
                                [ type' "button"
                                , class "btn btn-primary"
                                ]
                                [ glyphicon "send"
                                , text unbreakableSpace
                                , trans ResetPasswordText.SendToken
                                ]
                            ]
                        ]
                    , p [ class "help-block" ] [ text "Invalid" ] 
                    , p [ class "help-block" ] [ text "Required" ]
                    ]
                ]

        tokenSent =
            case focus.resetPasswordStatus of
                TokenSent ->
                    div [ class "alert alert-success text-left" ]
                        [ h4 [] [ trans ResetPasswordText.TokenSent ]
                        , p [] [ trans ResetPasswordText.TokenMessage ]
                        ]

                _ ->
                    div [] []
 
    in
        wrap <|
            [ h2 [] [ trans ResetPasswordText.Title ]
            , h3 [] [ trans ResetPasswordText.SendToken ]
            , p  [] [ trans ResetPasswordText.Blurb ]
            , emailForm
            , tokenSent
            , p [] [ trans ResetPasswordText.CreateAccount ] 
            , h3 [] [ trans ResetPasswordText.UseToken ]
            , p [] [ trans ResetPasswordText.UseTokenBlurb ]
            , tokenForm            
            ]


