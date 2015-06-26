module Focus.Types where

import Account.Login.Model exposing (Credentials)

type DesiredLocation
    = ReplacePath String
    | SetPath String

type Focus
    = Home
    | Error
    | Account AccountFocus

type AccountFocus
    = Settings
    | Password
    | Sessions
    | Logout
    | Login Credentials
    | Register
