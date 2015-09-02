module Date.Locale.LA (localize) where
{-| This module adds Latin names for months and weekdays.

# Extend
@docs localize
-}

import Date
import Date.Op


long : Date.Month -> String
long m = case m of
    Date.Jan -> "Ianuarius"
    Date.Feb -> "Februarius"
    Date.Mar -> "Martius"
    Date.Apr -> "Aprilis"
    Date.May -> "Maius"
    Date.Jun -> "Iunius"
    Date.Jul -> "Iulius"
    Date.Aug -> "Augustus"
    Date.Sep -> "September"
    Date.Oct -> "October"
    Date.Nov -> "November"
    Date.Dec -> "December"


short : Date.Month -> String
short m = case m of
    Date.Jan -> "Ian"
    Date.Feb -> "Feb"
    Date.Mar -> "Mar"
    Date.Apr -> "Apr"
    Date.May -> "Mai"
    Date.Jun -> "Iun"
    Date.Jul -> "Iul"
    Date.Aug -> "Aug"
    Date.Sep -> "Sep"
    Date.Oct -> "Oct"
    Date.Nov -> "Nov"
    Date.Dec -> "Déc"


day : Date.Day -> String
day d = case d of
    Date.Mon -> "Dies Lunae"
    Date.Tue -> "Dies Martis"
    Date.Wed -> "Dies Mercurii"
    Date.Thu -> "Dies Jovis"
    Date.Fri -> "Dies Veneris"
    Date.Sat -> "Dies Saturni"
    Date.Sun -> "Dies Solis"


localize : Date.Op.TokenDict -> Date.Op.TokenDict
localize = Date.Op.localize short long day
