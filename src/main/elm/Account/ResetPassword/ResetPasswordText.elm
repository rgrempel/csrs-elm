module Account.ResetPassword.ResetPasswordText where

import Language.LanguageTypes exposing (Language(..))
import Html exposing (Html, text, span, strong, a)
import Html.Events exposing (onClick)
import Focus.FocusTypes exposing (address, Action(FocusAccount))
import Account.AccountTypes exposing (Action(FocusRegister))
import Account.Register.RegisterTypes as RegisterTypes


type TextMessage
    = UsernamePlaceholder
    | PasswordPlaceholder

type HtmlMessage
    = Title 
    | SendToken
    | Token
    | Blurb
    | TokenSent
    | TokenMessage
    | CreateAccount
    | UseToken
    | UseTokenBlurb
    | EmailAddress


translateText : Language -> TextMessage -> String
translateText language message =
    case message of
        UsernamePlaceholder -> case language of
            EN -> "Your user name"
            FR -> "Votre nom d'utilisateur"
            LA -> "Nomen usoris tuum"

        PasswordPlaceholder -> case language of
            EN -> "Your password"
            FR -> "Votre mot de passe"
            LA -> "Signum tuum"

            
translateHtml : Language -> HtmlMessage -> Html 
translateHtml language message =
    case message of
        Title -> text <| case language of
            EN -> "Reset Password"
            FR -> "Réinitialiser mot de passe"
            LA -> "Signum retexere"

        SendToken -> text <| case language of
            EN -> "Send Token"
            FR -> "Envoyer jeton"
            LA -> "Indicium mittere"

        Token -> text <| case language of
            EN -> "Token"
            FR -> "Jeton"
            LA -> "Indicium"
        
        Blurb -> text <| case language of
            EN ->
                """
                To reset your password, provide your email address below. We
                will send you a token via email -- it should arrive within
                minutes. If it does not arrive, check whether it was marked as
                spam. You can also send another token from here if needed.
                """
            FR ->
                """
                Pour réinitialiser votre mot de passe, indiquez votre adresse
                email ci-dessous. Nous vous ferons parvenir un jeton par
                courriel - il devrait arriver en quelques minutes. Si vous ne
                le recevez pas, vérifiez si il a été marqué comme courrier
                indésirable. Vous pouvez également envoyer un autre jeton à
                partir d'ici si nécessaire.
                """
            LA ->
                """
                Signum retexere, praestate inscriptio electronica infra.
                Mittimus vobis indicium - intra minuta pervenerit. Si non
                venit, si hæc ita se ut spamma. Alium hinc indicium potes si
                opus fuerit.
                """
        
        TokenSent -> text <| case language of
            EN -> "Token Sent"
            FR -> "Jeton a été envoyée"
            LA -> "Indicium missum"

        TokenMessage -> text <| case language of
            EN -> "Your token has been sent, and should arrive soon."
            FR -> "Votre jeton a été envoyée, et devrait arriver bientôt."
            LA -> "Indicium missus est, et mox advenient."
        
        CreateAccount ->
            let
                action =
                    onClick address <| FocusAccount <| FocusRegister RegisterTypes.FocusBlank

            in
                span [] <| case language of
                    EN ->
                        [ text "If you need to create a new account, then you can "
                        , a [ action ] [ text "request an invitation." ]
                        ]
                    FR ->
                        [ text "Si vous avez besoin de créer un nouveau compte, alors vous pouvez "
                        , a [ action ] [ text "demander une invitation." ]
                        ]
                    LA ->
                        [ text "Si opus tesseram novum, "
                        , a [ action ] [ text "invitationem petere" ]
                        , text "igitur."
                        ]

        UseToken -> text <| case language of
            EN -> "Use Token"
            FR -> "Utiliser jeton"
            LA -> "Indicium utuntur"

        UseTokenBlurb -> text <| case language of
            EN ->
                """
                If you already have a token to reset your password, paste it
                below. The token should be a long number.
                """
            FR ->
                """
                Si vous avez un jeton pour réinitialiser votre mot de passe,
                collez-le ci-dessous. Le jeton doit être un long numéro.
                """
            LA ->
                """
                Iam si indicium signum retexere, crustulum infra. Indicium
                debet esse numerus longum.
                """

        EmailAddress -> text <| case language of
            EN -> "Email Address"
            FR -> "Email"
            LA -> "Inscriptio electronica"

