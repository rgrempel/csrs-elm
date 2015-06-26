module Model where

import Translation.Model as MT
import Focus.Model as MF 
import Account.Login.Model as ML
import Types exposing (Model)
import Focus.Types as FT 

initialModel : Model
initialModel =
    { useLanguage = MT.defaultLanguage
    , focus = MF.initialFocus
    , desiredLocation = Nothing
    }

extractCredentials : Model -> ML.Credentials
extractCredentials model =
    case model.focus of
        FT.Account (FT.Login credentials) -> credentials
        _ -> ML.defaultCredentials
        

