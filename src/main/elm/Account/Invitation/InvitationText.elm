module Account.Invitation.InvitationText where

import Language.LanguageTypes exposing (Language(..))
import Html exposing (Html, text, span, strong, a)


type Message
    = Title
    | Blurb
    | Key
    | UseThisInvitation
    | NotFound
    | TryAgain
    

translate : Language -> Message -> Html 
translate language message =
    text <| case message of
        Title -> case language of
            EN -> "Use an Invitation"
            FR -> "Utiliser une invitation"
            LA -> "Invitatio utuntur"

        UseThisInvitation -> case language of
            EN -> "Use Invitation"
            FR -> "Utiliser invitation"
            LA -> "Invitatio utuntur"

        Key -> case language of
            EN -> "Invitation key"
            FR -> "Clé d'invitation"
            LA -> "Clavem invitatio"

        NotFound -> case language of
            EN -> "Invitation not found"
            FR -> "Invitation introuvable"
            LA -> "Invitatio non inveni"

        TryAgain -> case language of
            EN ->
                """
                This invitation key was not found, or has already been used.
                Please check the key and try again.
                """
            FR ->
                """
                Cette clé d'invitation n'a pas été trouvé, ou a déjà été utilisé.
                Se il vous plaît vérifier la clé et essayez à nouveau.
                """
            LA ->
                """
                Quae clavem invitatio non est inventus, aut iam redemptis. 
                Probā clavem ac aliquam.
                """

        Blurb -> case language of
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
