-- Example.elm
import String
import Graphics.Element exposing (Element)

import ElmTest.Test exposing (test, Test, suite)
import ElmTest.Assertion exposing (assert, assertEqual)
import ElmTest.Runner.Element exposing (runDisplay)

import Focus.ModelTest exposing (tests)

allTests : Test
allTests = tests

main : Element
main = runDisplay allTests

