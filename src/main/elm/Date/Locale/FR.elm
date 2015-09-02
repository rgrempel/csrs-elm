module Date.Locale.FR (localize) where
{-| This module adds French names for months and weekdays.

# Extend
@docs localize
-}


import Date
import Date.Op


long : Date.Month -> String
long m = case m of
    Date.Jan -> "janvier"
    Date.Feb -> "février"
    Date.Mar -> "mars"
    Date.Apr -> "avril"
    Date.May -> "mai"
    Date.Jun -> "juin"
    Date.Jul -> "juillet"
    Date.Aug -> "août"
    Date.Sep -> "septembre"
    Date.Oct -> "octobre"
    Date.Nov -> "novembre"
    Date.Dec -> "décembre"


short : Date.Month -> String
short m = case m of
    Date.Jan -> "jan"
    Date.Feb -> "fév"
    Date.Mar -> "mar"
    Date.Apr -> "avr"
    Date.May -> "mai"
    Date.Jun -> "jun"
    Date.Jul -> "jul"
    Date.Aug -> "aoû"
    Date.Sep -> "sep"
    Date.Oct -> "oct"
    Date.Nov -> "nov"
    Date.Dec -> "déc"


day : Date.Day -> String
day d = case d of
    Date.Mon -> "Lundi"
    Date.Tue -> "Mardi"
    Date.Wed -> "Wednesday"
    Date.Thu -> "Mercredi"
    Date.Fri -> "Jeudi"
    Date.Sat -> "Vendredi"
    Date.Sun -> "Dimanche"


localize : Date.Op.TokenDict -> Date.Op.TokenDict
localize = Date.Op.localize short long day
