module Cookies where

import Native.Cookies
import Task exposing (Task, andThen)
import String exposing (split, trim)
import List exposing (map, filterMap)
import Dict exposing (Dict, fromList)
import Http exposing (uriDecode, send)


type alias Cookies = Dict String String


getCookieString : Task x String
getCookieString =
    Native.Cookies.getCookieString


getCookies : Task x Cookies
getCookies =
    Task.map cookieString2Dict getCookieString


list2tuple : List a -> Maybe (a, a)
list2tuple list =
    case list of
        first :: second :: _ ->
            Just (first, second)

        _ ->
            Nothing


uriDecodeTuple : (String, String) -> (String, String)
uriDecodeTuple (a, b) =
    (uriDecode a, uriDecode b)


cookieString2Dict : String -> Cookies 
cookieString2Dict cookieString =
    let
        listOfTrimmedCookies =
            map trim (split ";" cookieString)

        listOfLists =
            map (split "=") listOfTrimmedCookies

        listOfTuples =
            filterMap list2tuple listOfLists

        decodedListOfTuples =
            map uriDecodeTuple listOfTuples

    in
        fromList decodedListOfTuples


