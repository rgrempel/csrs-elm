module Test where

import String
import Graphics.Element exposing (Element)
import ElmTest.Test exposing (test, Test, suite)
import ElmTest.Assertion exposing (assert, assertEqual)
import ElmTest.Runner.Element exposing (runDisplay)

import Route.RouteTest as RouteTest


allTests : Test
allTests = RouteTest.tests

main : Element
main = runDisplay allTests

