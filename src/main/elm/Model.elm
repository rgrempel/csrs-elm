module Model where

import Model.Translation as MT
import Model.Focus as MF 

type alias Model =
    { useLanguage : MT.Language
    , focus : MF.Focus
    , updateLocation: MF.UpdateLocation
    }

initialModel : Model
initialModel =
    { useLanguage = MT.defaultLanguage
    , focus = MF.initialFocus
    , updateLocation = MF.initialUpdateLocation
    }

