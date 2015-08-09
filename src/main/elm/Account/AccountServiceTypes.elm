module Account.AccountServiceTypes where

import Language.LanguageTypes as LanguageTypes exposing (Language)
import Http exposing (uriEncode, url, string, defaultSettings, fromJson, Settings, Request, Response, Error(BadResponse), RawError(RawTimeout, RawNetworkError))
import Signal exposing (Mailbox, Address, mailbox)
import Task exposing (Task, map, mapError, succeed, fail, onError, andThen, toResult)
import Json.Decode as JD exposing ((:=))
import String exposing (toUpper)


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


roleDecoder : JD.Decoder Role
roleDecoder =
    JD.string `JD.andThen` \s ->
        case (toUpper s) of
            "ROLE_ADMIN" ->
                JD.succeed RoleAdmin

            "ROLE_USER" ->
                JD.succeed RoleUser

            _ ->
                JD.fail <| s ++ " is not a role I recognize"


type alias User =
    { username : String
    , langKey: Language
    , roles: Maybe (List Role) 
    }


userDecoder : JD.Decoder User
userDecoder =
    let
        withRoles =
            JD.object3 User
                ("login" := JD.string)
                ("langKey" := LanguageTypes.decoder)
                ("roles" := JD.maybe (JD.list roleDecoder))

        withoutRoles =
            JD.object3 User
                ("login" := JD.string)
                ("langKey" := LanguageTypes.decoder)
                (JD.succeed Nothing)

    in
        JD.oneOf [withRoles, withoutRoles]


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
        ("user" := JD.maybe userDecoder)

type alias Email =
    { id : Int
    , emailAddress : String
    }

emailDecoder : JD.Decoder Email
emailDecoder =
    JD.object2 Email
        ("id" := JD.int)
        ("emailAddress" := JD.string)


