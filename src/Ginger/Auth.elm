module Ginger.Auth exposing
    ( Status(..)
    , Identity
    , Method(..)
    , requestLogin
    , requestLogout
    , requestSignup
    , requestStatus
    , requestReset
    , fromResult
    , fromJson
    )

{-|


# Definition

@docs Status
@docs Identity
@docs Method


# Http

@docs requestLogin
@docs requestLogout
@docs requestSignup
@docs requestStatus
@docs requestReset

@docs fromResult


# Decode

@docs fromJson

-}

import Http
import Iso8601
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Time



-- DEFINITIONS


{-| -}
type Status
    = Authenticated Identity (Maybe Decode.Value)
    | Anonymous
    | Loading
    | Error Http.Error


{-| -}
type alias Identity =
    { id : Int
    , resourceId : Int
    , method : Method
    , key : String
    , unique : Bool
    , verified : Bool
    , created : Time.Posix
    , modified : Time.Posix
    , lastVisit : Time.Posix
    }


{-| The method used for creating an identity
-}
type Method
    = Ginger
    | Facebook
    | Instagram
    | LinkedIn
    | Twitter
    | Unknown String



-- REQUESTS


{-| -}
requestLogin : (Result Http.Error Status -> msg) -> String -> String -> Cmd msg
requestLogin msg username password =
    let
        body =
            Encode.object
                [ ( "username", Encode.string username )
                , ( "password", Encode.string password )
                ]
    in
    Http.post
        { url = "/data/auth/login"
        , body = Http.jsonBody body
        , expect = Http.expectJson msg fromJson
        }


{-| -}
requestSignup : (Result Http.Error () -> msg) -> String -> String -> Cmd msg
requestSignup msg username password =
    let
        body =
            Encode.object
                [ ( "email", Encode.string username )
                , ( "password", Encode.string password )
                ]
    in
    Http.post
        { url = "/data/auth/new"
        , body = Http.jsonBody body
        , expect = Http.expectWhatever msg
        }


{-| -}
requestReset : (Result Http.Error () -> msg) -> String -> Cmd msg
requestReset msg username =
    let
        body =
            Encode.object
                [ ( "email", Encode.string username ) ]
    in
    Http.post
        { url = "/data/auth/reset"
        , body = Http.jsonBody body
        , expect = Http.expectWhatever msg
        }


{-| -}
requestStatus : (Result Http.Error Status -> msg) -> Cmd msg
requestStatus msg =
    Http.get
        { url = "/data/auth/status"
        , expect = Http.expectJson msg fromJson
        }


{-| -}
requestLogout : (Result Http.Error () -> msg) -> Cmd msg
requestLogout msg =
    Http.post
        { url = "/data/auth/logout"
        , body = Http.emptyBody
        , expect = Http.expectWhatever msg
        }



-- ERROR


{-| -}
fromResult : Result Http.Error Status -> Status
fromResult result =
    case result of
        Ok status ->
            status

        Err err ->
            Error err



-- DECODERS


{-| -}
fromJson : Decode.Decoder Status
fromJson =
    Decode.succeed Authenticated
        |> Pipeline.required "identity" identityFromJson
        |> Pipeline.optional "resource" (Decode.map Just Decode.value) Nothing


{-| Decode a Ginger identity json value to an Identity record
-}
identityFromJson : Decode.Decoder Identity
identityFromJson =
    Decode.succeed Identity
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "rsc_id" Decode.int
        |> Pipeline.required "type" decodeIdentityType
        |> Pipeline.required "key" Decode.string
        |> Pipeline.required "is_unique" Decode.bool
        |> Pipeline.required "is_verified" Decode.bool
        |> Pipeline.required "created" Iso8601.decoder
        |> Pipeline.required "modified" Iso8601.decoder
        |> Pipeline.required "visited" Iso8601.decoder


decodeIdentityType : Decode.Decoder Method
decodeIdentityType =
    Decode.andThen identityTypeFromString <|
        Decode.string


identityTypeFromString : String -> Decode.Decoder Method
identityTypeFromString type_ =
    Decode.succeed <|
        case type_ of
            "username_pw" ->
                Ginger

            "twitter" ->
                Twitter

            "facebook" ->
                Facebook

            "instagram" ->
                Instagram

            "linkedin" ->
                LinkedIn

            other ->
                Unknown other
