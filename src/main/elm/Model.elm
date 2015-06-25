module Model where

import Model.Translation as MT
import Model.Focus as MF 
import Model.Login as ML

type alias Model =
    { useLanguage : MT.Language
    , focus : MF.Focus
    , desiredLocation : Maybe MF.DesiredLocation
    , credentials : Maybe ML.Credentials
    }

initialModel : Model
initialModel =
    { useLanguage = MT.defaultLanguage
    , focus = MF.initialFocus
    , desiredLocation = Nothing
    , credentials = Nothing
    }

