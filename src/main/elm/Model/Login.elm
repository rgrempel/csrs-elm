module Model.Login where

type alias Credentials =
    { username: String
    , password: String
    , rememberMe: Bool
    }

