module Functor where

import String
import Graphics.Element exposing (Element)

import ElmTest.Test exposing (test, Test, suite)
import ElmTest.Assertion exposing (assert, assertEqual)
import ElmTest.Runner.Element exposing (runDisplay)


{- listFunctor : Functor List m -}
composableListFunctor m =
    { m
        | fmap = List.map
    }

listFunctor = composableListFunctor {}

composableMaybeFunctor m =
    { m
        | fmap = \func maybe ->
            case maybe of
                Just something -> Just (func something)
                Nothing -> Nothing
    }

maybeFunctor = composableMaybeFunctor {}

{-
type alias Functor f a b m =
    { m 
        | fmap : (a -> b) -> f a -> f b
    }
-}

{-
type alias ComposableFunctor m a b box1 box2 =
    { m |
        fmap : (a -> b) -> box1 -> box2
    }


type alias Functor = ComposableFunctor {}


replace : b -> (v, Functor y b {}) -> (e, Functor {})
-}

replace b (a, f) =
    ( f.fmap (always b) a, f )


fmap func (a, f) =
    ( f.fmap func a, f )


allTests : Test
allTests = 
    suite "Focus"
        [ test "replace with a list" <|
            assertEqual [42, 42]  
                <| fst <| replace 42 (["onestring", "twostring"], listFunctor)
        , test "replace with different kind of list" <|
            assertEqual ["string", "string"] 
                <| fst <| replace "string" ([42, 43], listFunctor)
        , test "generic fmap with list" <|
            assertEqual ["something", "somebody"]
                <| fst <| fmap ( \a -> "some" ++ a ) (["thing", "body"], listFunctor)
        , test "generic fmap with list chained" <|
            assertEqual ["something-oh", "somebody-oh"]
                <| fst 
                <| fmap ( \b -> b ++ "-oh" )
                <| fmap ( \a -> "some" ++ a ) (["thing", "body"], listFunctor)
        , test "generic fmap with maybe" <|
            assertEqual (Just "something")
                <| fst <| fmap ( \a -> "some" ++ a ) (Just "thing", maybeFunctor)
        , test "generic fmap with nothing" <|
            assertEqual (Nothing)
                <| fst <| fmap ( \a -> "some" ++ a ) (Nothing, maybeFunctor)
        , test "replace maybe thingy" <|
            assertEqual (Just 42)
                <| fst <| replace 42 (Just "bob", maybeFunctor)
        ]


main : Element
main = runDisplay allTests


{-
module Functor where

import List

type alias Functor f = { fmap : (a -> b) -> f a -> f b }

maybeFunctor : Functor Maybe
maybeFunctor = { fmap func ma = case ma of
                                  Just a -> func a
                                  Nothing -> Nothing }

listFunctor : Functor List
listFunctor = { fmap = List.map }

signalFunctor : Functor Signal
signalFunctor = { fmap = Signal.map }

taskFunctor : Functor Task
taskFunctor = { fmap = Task.map }


-- Haskell:
replace :: Functor f => b -> f a -> f b

-- Elm:
replace : Functor f -> b -> f a -> f b
replace f b fa = f.fmap (always b) fa



type alias Monad m = { succeed : a -> m a
                       join : m (m a) -> m a }
{-
type alias Monad m a = { m | 
                             succeed : 
                             join :  -}
-}
