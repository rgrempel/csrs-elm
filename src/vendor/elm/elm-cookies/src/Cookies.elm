module Cookies 
    ( get
    , set
    , setWithOptions
    , defaultOptions
    , Options
    ) where

{-| Elm API for cookies.

# Getting cookies 
@docs get

# Setting cookies
@docs set, setWithOptions, Options, defaultOptions
-}

import Native.Cookies
import Task exposing (Task)
import String exposing (split, trim, join)
import Dict exposing (Dict, insert)
import Http exposing (uriDecode, uriEncode)
import Time exposing (inSeconds, Time)
import Date exposing (Date)
import List exposing (intersperse)


{-| A task whose result will be the cookies.

In the resulting Dict, the keys and values are the key=value pairs parsed from
Javascript's document.cookie. The keys and values will have been uriDecoded.

-}
get : Task x (Dict String String)
get =
    Task.map cookieString2Dict getString


getString : Task x String
getString =
    Native.Cookies.getString


{- 
We pipeline the various operations inside the foldl so that we don't
iterate over the cookies more then once.  Note that the uriDecode needs to
happen after the split on ';' (to divide into key-value pairs) and the split on
'=' (to divide the keys from the values).
-}
cookieString2Dict : String -> Dict String String
cookieString2Dict =
    let
        addCookieToDict =
            trim >> split "=" >> List.map uriDecode >> addKeyValueToDict

        addKeyValueToDict keyValueList =
            case keyValueList of
                key :: value :: _ -> insert key value
                _ -> identity

    in
        List.foldl addCookieToDict Dict.empty << split ";"


{-| A task which will set a cookie using the provided key and value.

The key and value will both be uriEncoded.

-}
set : String -> String -> Task x ()
set = setWithOptions defaultOptions


{-| Options which you can provide to setWithOptions.

-}
type alias Options =
    { path : Maybe String
    , domain : Maybe String
    , maxAge : Maybe Time
    , expires : Maybe Date 
    , secure : Maybe Bool
    }


{-| The default options, in which all options are set to Nothing.

You can use this as a starting point for setWithOptions, where you
only want to specify some options.

-}
defaultOptions : Options
defaultOptions =
    { path = Nothing
    , domain = Nothing
    , maxAge = Nothing
    , expires = Nothing
    , secure = Nothing
    }


{-| A task which will set a cookie using the provided options, key and value.

The key and value will be uriEncoded, as well as the path and domain options (if provided).
-}
setWithOptions : Options -> String -> String -> Task x ()
setWithOptions options key value =
    let
        andThen =
            flip Maybe.andThen

        handlers =
            [ always <| Just <| (uriEncode key) ++ "=" ++ (uriEncode value)
            , .path >> andThen (\path -> Just <| "path=" ++ uriEncode path)
            , .domain >> andThen (\domain -> Just <| "domain=" ++ uriEncode domain)
            , .maxAge >> andThen (\age -> Just <| "max-age=" ++ toString (inSeconds age))
            , .expires >> andThen (\expires -> Just <| "expires=" ++ dateToUTCString expires)
            , .secure >> andThen (\secure -> if secure then Just "secure" else Nothing)
            ]

        cookieStrings =
            List.filterMap ((|>) options) handlers

    in
        setString <| join ";" cookieStrings


setString : String -> Task x ()
setString =
    Native.Cookies.setString


dateToUTCString : Date -> String
dateToUTCString =
    Native.Cookies.dateToUTCString
