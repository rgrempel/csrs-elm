module Account.PasswordStrengthBar.PasswordStrengthBar where

import Account.PasswordStrengthBar.PasswordStrengthBarText as PSBText
import Language.LanguageService exposing (Language)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import List exposing (repeat, filter, foldl, map)
import Regex exposing (regex, contains)
import String

-- This is adapted from the JHipster password strength bar


strength : String -> Int
strength password =
    let
        symbols = regex "[$-/:-?{-~!\"^_`\\[\\]]"
        lower = regex "[a-z]+"
        upper = regex "[A-Z]+"
        numbers = regex "[0-9]+"

        matches =
            List.length <| 
                filter ((flip contains) password)
                    [ symbols
                    , lower
                    , upper
                    , numbers
                    ]  
        
        length =
            String.length password

        score =
            (length * 2) +
            (if length >= 10 then 1 else 0) +
            (matches * 10)

        ceilings =
            [ (length <= 6, 10)
            , (matches == 1, 10)
            , (matches == 2, 20)
            , (matches == 3, 40)
            ]

        applyCeiling ceiling score =
            case ceiling of
                (False, _) -> score
                (True, most) -> max most score

    in
        foldl applyCeiling score ceilings


draw : Language -> String -> Html
draw language password =
    let
        trans =
            PSBText.translate language

        score =
            strength password

        color =
            if  | score <= 10 -> ("#F00", 1) 
                | score <= 20 -> ("#F90", 2)
                | score <= 30 -> ("#FF0", 3)
                | score <= 40 -> ("#9F0", 4)
                | otherwise -> ("#0F0", 5) 
       
        indexColor index =
            if index <= snd color
                then fst color
                else "#DDD"

        point index =
            li 
                [ class "point"
                , style [("background", indexColor index)]
                ] []
            
    in
        div [ class "password-strength-bar" ]
            [ small [] [ trans PSBText.PasswordStrength ]
            , div [] 
                [ ul [] <| map point [1 .. 5]
                ]
            ]
