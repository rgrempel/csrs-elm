module Focus.Model where

import String exposing (uncons)
import Focus.Types exposing (..) 
import Account.Login.Model exposing (defaultCredentials)

initialFocus = Home

hashPrefix = "#!/"

-- Remove initial characters from the string, as many as there are.
-- So, for "#!/", remove # if is first, then ! if it is next, etc.
removeAnyInitial : String -> String -> String
removeAnyInitial initial original =
    String.foldl removeInitial original initial

removeInitial : Char -> String -> String
removeInitial initial original =
    case uncons original of
        Just (first, rest) -> if first == initial then rest else original
        _ -> original

type alias Hash = String

hash2focus : Hash -> Focus
hash2focus hash =
    case removeAnyInitial hashPrefix hash of
        "" -> Home
        "settings" -> Account Settings
        "password" -> Account Password
        "sessions" -> Account Sessions
        "logout" -> Account Logout
        "login" -> Account <| Login defaultCredentials
        "register" -> Account Register
        _ -> Error 

focus2hash : Focus -> Hash
focus2hash focus =
    hashPrefix
    ++
    case focus of
        Home -> ""
        Error -> "error"
        Account account ->
            case account of
                Settings -> "settings"
                Password -> "password"
                Sessions -> "sessions"
                Logout -> "logout"
                Login _ -> "login"
                Register -> "register"
