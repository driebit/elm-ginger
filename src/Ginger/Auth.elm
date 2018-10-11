module Ginger.Auth exposing
    ( Status(..)
    , requestAuthentication
    , statusFromResult
    , fromJson
    )

{-|


# Definitions

@docs Status


# Http

@docs requestAuthentication
@docs statusFromResult


# Decode

@docs fromJson

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
    | Error String



-- REQUESTS


{-| -}
requestAuthentication : String -> String -> Http.Request Status
requestAuthentication username password =
    let
        body =
            Encode.object
                [ ( "username", Encode.string username )
                , ( "password", Encode.string password )
                ]
    in
    Http.post "/data/auth" (Http.jsonBody body) fromJson



-- DECODERS


{-| -}
fromJson : Decode.Decoder Status
fromJson =
    Decode.succeed Authenticated
        |> Pipeline.required "identity" Identity.fromJson
        |> Pipeline.optional "resource" (Decode.maybe Ginger.Resource.fromJson) Nothing



-- ERROR


{-| -}
statusFromResult : Result Http.Error Status -> Status
statusFromResult result =
    case result of
        Ok status ->
            status

        Err (Http.BadStatus { body }) ->
            Error body

        _ ->
            Error "Http error"
