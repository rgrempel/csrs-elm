module Validation.ValidationTypes where

import Dict exposing (Dict)

type Validator a
    = Required
    | Email
    | GreaterThan a
    | Between a a
    | MinLength Int
    | MaxLength Int
    | Matches a
    | NotTaken (Dict a Bool)


type alias StringValidator = Validator String
type alias IntValidator = Validator Int
type alias FloatValidator = Validator Float
