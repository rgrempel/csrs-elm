module Components.Account.Register.RegisterText where

import Language.LanguageTypes exposing (Language(..))
import Html exposing (Html, text, span, strong, a)
import Html.Events exposing (onClick)

import Components.FocusTypes exposing (Action(FocusAccount), address)
import Components.Account.AccountTypes exposing (Action(FocusLogin, FocusResetPassword))
import Components.Account.Login.LoginTypes as LoginTypes
import Components.Account.ResetPassword.ResetPasswordTypes as ResetPasswordTypes


type TextMessage
    = UsernamePlaceholder
    | PasswordPlaceholder

type HtmlMessage
    = CreateNewAccount 
    | RequestInvitation
    | CreateAccountBlurb
    | EmailAddress
    | SendInvitation
    | InvitationSent
    | InvitationMessage
    | PasswordReset
    | TryLogin
    | InvitationBlurb
    | InvitationKey
    | UseInvitation


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
        CreateNewAccount -> text <| case language of
            EN -> "Create Account"
            FR -> "Créer un compte"
            LA -> "Subsigno"

        {- or ...
            en: "Create Account"
            fr: "Création de compte utilisateur"
            la: "Tesseram creare"
        -}

        RequestInvitation -> text <| case language of
            EN -> "Get an Invitation"
            FR -> "Obtenir une invitation"
            LA -> "Obtinere invitatio"

        CreateAccountBlurb -> text <| case language of
            EN ->
                """
                To create an account, provide your email address below. We will
                send you an email invitation -- it should arrive within
                minutes. If it does not arrive, check whether it was marked as
                spam. You can also send another invitation from here if needed.
                """
            FR ->
                """
                Pour créer un compte, indiquez votre adresse email ci-dessous.
                Nous vous enverrons une invitation par courriel - il devrait
                arriver en quelques minutes. Se il ne arrive pas, vérifier se
                il a été marqués comme courrier indésirable. Vous pouvez
                également envoyer une autre invitation à partir d'ici si
                nécessaire.
                """
            LA ->
                """
                Tesseram creare, praestate inscriptio electronica infra.
                Mittemus vobis inuitavit -- intra minuta pervenerit. Si non
                venit, si hæc ita se ut spamma. Etiam si opus mittere hinc
                invitationem alius.
                """

        EmailAddress -> text <| case language of
            EN -> "Email Address"
            FR -> "Email"
            LA -> "Inscriptio electronica"

        SendInvitation -> text <| case language of
            EN -> "Send Invitation"
            FR -> "Envoyer une invitation"
            LA -> "Mittentes vocabant"

        InvitationSent -> text <| case language of
            EN -> "Invitation Sent"
            FR -> "Invitation a été envoyée"
            LA -> "Invitatio missum"

        InvitationMessage -> text <| case language of
            EN -> "Your invitation has been sent, and should arrive soon."
            FR -> "Votre invitation a été envoyée, et devrait arriver bientôt."
            LA -> "Invitatio missus est, et mox advenient."

        UseInvitation -> text <| case language of
            EN -> "Use Invitation"
            FR -> "Utiliser invitation"
            LA -> "Invitatio utuntur"

        InvitationKey -> text <| case language of
            EN -> "Invitation key"
            FR -> "Clé d'invitation"
            LA -> "Clavem invitatio"
            
        InvitationBlurb -> text <| case language of
            EN ->
                """
                If you have an invitation to create an account or reset your
                password, paste the key below. The key should be a long number.
                """
            FR ->
                """
                Si vous avez une invitation à créer un compte ou réinitialiser
                votre mot de passe, collez la clé ci-dessous. La clé doit être
                un long numéro.
                """
            LA ->
                """
                Si invitationem tesserae creant aut signum retexeret, crustulum
                clavem infra. Clavem debet esse numerus longum.
                """

        TryLogin ->
            let
                action =
                    onClick address <| FocusAccount <| FocusLogin LoginTypes.FocusBlank

            in
                span [] <| case language of
                    EN ->
                        [ text "If you already have an account, "
                        , a [ action ] [ text "try logging in" ]
                        , text " with your username and password "
                        ]
                    FR ->
                        [ text "If you already have an account, "
                        , a [ action ] [ text "try logging in" ]
                        , text " with your username and password "
                        ]
                    LA ->
                        [ text "If you already have an account, "
                        , a [ action ] [ text "try logging in" ]
                        , text " with your username and password "
                        ]

        PasswordReset ->
            let
                action =
                    onClick address <| FocusAccount <| FocusResetPassword ResetPasswordTypes.FocusBlank

            in
                span [] <| case language of
                    EN ->
                        [ text 
                            "If you have forgotten your username or password,
                            then try the "
                        , a [ action ] [ text "password reset" ]
                        , text " page."
                        ]
                    FR ->
                        [ text
                            "Si vous avez oublié le nom d'utilisateur ou mot de
                            passe, puis essayez le "
                        , a [ action ] [ text "mot de passe réinitialiser." ]
                        ]
                    LA ->
                        [ text "Iam obliti usoris aut signo, tum istoc " 
                        , a [ action ] [ text "signum retexere." ]
                        ]

