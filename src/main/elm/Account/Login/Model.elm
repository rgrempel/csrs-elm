module Account.Login.Model where

type alias Credentials =
    { username: String
    , password: String
    , rememberMe: Bool
    }

defaultCredentials : Credentials
defaultCredentials =
    { username = ""
    , password = ""
    , rememberMe = False
    }

