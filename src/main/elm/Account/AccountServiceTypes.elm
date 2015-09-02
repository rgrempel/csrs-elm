module Account.AccountServiceTypes where

import Language.LanguageTypes as LanguageTypes exposing (Language, defaultLanguage)
import Http exposing (uriEncode, url, string, defaultSettings, fromJson, Settings, Request, Response, Error(BadResponse), RawError(RawTimeout, RawNetworkError))
import Signal exposing (Mailbox, Address, mailbox)
import Task exposing (Task, map, mapError, succeed, fail, onError, andThen, toResult)
import Json.Decode as JD exposing ((:=), oneOf)
import String exposing (toUpper)
import Result


type LoginError
    = LoginWrongPassword  -- 401
    | LoginHttpError Http.Error


type CreateAccountError
    = UserAlreadyExists String   -- 400
    | CreateAccountHttpError Http.Error


type Action
    = SetCurrentUser (Maybe User)
    | NoOp

type alias Credentials =
    { username: String
    , password: String
    , rememberMe: Bool
    }

type Role
    = RoleUser
    | RoleAdmin


roleFromString : String -> Result String Role
roleFromString s =
    case (toUpper s) of
        "ROLE_ADMIN" ->
            Result.Ok RoleAdmin

        "ROLE_USER" ->
            Result.Ok RoleUser

        _ ->
            Result.Err <| s ++ " is not a role I recognize"


roleDecoder : JD.Decoder Role
roleDecoder =
    JD.customDecoder JD.string roleFromString


type alias User =
    { username : String
    , langKey: Language
    , roles: Maybe (List Role) 
    }


userDecoder : JD.Decoder User
userDecoder =
    JD.object3 User
        ( "login" := JD.string )
        ( oneOf 
            [ "langKey" := LanguageTypes.decoder
            , JD.succeed defaultLanguage 
            ]
        )
        ( JD.maybe <| "roles" := (JD.list roleDecoder) )


type alias Session =
    { series : String
    , ipAddress : Maybe String
    , userAgent : Maybe String
    , date : Maybe String
    }

sessionDecoder : JD.Decoder Session
sessionDecoder =
    JD.object4 Session
        ( "series" := JD.string )
        ( JD.maybe <| "ipAddress" := JD.string )
        ( JD.maybe <| "userAgent" := JD.string )
        ( JD.maybe <| "formattedTokenDate" := JD.string )


type alias AccountModel m =
    { m | currentUser : Maybe User }


initialModel : m -> AccountModel m
initialModel model = AccountModel Nothing model


actions : Mailbox Action
actions = mailbox NoOp 


do : Action -> Task x ()
do = Signal.send actions.address


type alias CreateAccountInfo =
    { username : String
    , password : String
    , language : Language
    , activationKey : String
    }


type alias UserEmailActivation =
    { id : Int
    , userEmail : UserEmail
    , activationKey : String
    }


userEmailActivationDecoder : JD.Decoder UserEmailActivation
userEmailActivationDecoder =
    JD.object3 UserEmailActivation
        ("id" := JD.int)
        ("userEmail" := userEmailDecoder)
        ("activationKey" := JD.string)

type alias UserEmail =
    { id : Int
    , email : Email
    , user : Maybe User
    }

userEmailDecoder : JD.Decoder UserEmail
userEmailDecoder =
    JD.object3 UserEmail
        ("id" := JD.int)
        ("email" := emailDecoder)
        (JD.maybe <| "user" := userDecoder)

type alias Email =
    { id : Int
    , emailAddress : String
    }

emailDecoder : JD.Decoder Email
emailDecoder =
    JD.object2 Email
        ("id" := JD.int)
        ("emailAddress" := JD.string)


