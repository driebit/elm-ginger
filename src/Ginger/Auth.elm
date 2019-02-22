module Ginger.Auth exposing
    ( Status(..)
    , requestAuthentication
    , requestStatus
    , fromResult
    , fromJson
    , isAuthenticated
    , requestLogout, requestReset, requestSignup
    )

{-|


# Definitions

@docs Status


# Http

@docs requestAuthentication
@docs requestStatus
@docs fromResult


# Decode

@docs fromJson
@docs isAuthenticated

-}

import Ginger.Auth.Identity as Identity exposing (Identity)
import Ginger.Resource exposing (Resource)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode



-- DEFINITIONS


{-| -}
type Status
    = Authenticated Identity (Maybe Resource)
    | Anonymous
    | Loading
    | Error Http.Error



-- REQUESTS


{-| -}
requestAuthentication : (Result Http.Error Status -> msg) -> String -> String -> Cmd msg
requestAuthentication msg username password =
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



-- DECODERS


{-| -}
fromJson : Decode.Decoder Status
fromJson =
    Decode.succeed Authenticated
        |> Pipeline.required "identity" Identity.fromJson
        |> Pipeline.optional "resource" (Decode.maybe Ginger.Resource.fromJson) Nothing



-- ERROR


{-| -}
fromResult : Result Http.Error Status -> Status
fromResult result =
    case result of
        Ok status ->
            status

        Err err ->
            Error err



-- HELPERS


isAuthenticated : Status -> Bool
isAuthenticated status =
    case status of
        Authenticated _ _ ->
            True

        _ ->
            False
