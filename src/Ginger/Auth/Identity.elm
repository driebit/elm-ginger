module Ginger.Auth.Identity exposing
    ( Identity
    , Method(..)
    , fromJson
    )

{-|


# Definitions

@docs Identity
@docs Method


# Decode

@docs fromJson

-}

import Iso8601
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Time



-- DEFINITIONS


{-| The method used for creating an identity
-}
type Method
    = Ginger
    | Facebook
    | Instagram
    | LinkedIn
    | Twitter
    | Unknown String


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



-- DECODERS


{-| Decode a Ginger identity json value to an Identity record
-}
fromJson : Decode.Decoder Identity
fromJson =
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
