module Validation.ValidationTypes where


type Validator a
    = Required
    | Email
    | GreaterThan a
    | Between a a
    | MinLength Int
    | MaxLength Int
    | Matches a 


type alias StringValidator = Validator String
type alias IntValidator = Validator Int
type alias FloatValidator = Validator Float
