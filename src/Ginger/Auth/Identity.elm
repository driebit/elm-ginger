module Ginger.Auth.Identity exposing (Identity, Type(..), fromJson)

import Iso8601
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Time



-- DEFINITIONS


type Type
    = UsernamePassword
    | Unknown String


type alias Identity =
    { id : Int
    , resourceId : Int
    , type_ : Type
    , username : String
    , unique : Bool
    , verified : Bool
    , created : Time.Posix
    , modified : Time.Posix
    , lastVisit : Time.Posix
    }



-- DECODERS


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


decodeIdentityType : Decode.Decoder Type
decodeIdentityType =
    Decode.andThen identityTypeFromString <|
        Decode.string


identityTypeFromString : String -> Decode.Decoder Type
identityTypeFromString type_ =
    Decode.succeed <|
        case type_ of
            "username_pw" ->
                UsernamePassword

            other ->
                Unknown other
