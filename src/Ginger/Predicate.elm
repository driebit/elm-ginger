module Ginger.Predicate exposing
    ( Predicate(..)
    , toString
    , fromString
    , fromJson
    )

{-|


# Definition

@docs Predicate


# Conversions

@docs toString
@docs fromString


# Decode

@docs fromJson

-}

import Json.Decode as Decode
import Json.Decode.Extra as Decode



-- DEFINITIONS


{-| -}
type Predicate
    = IsAbout
    | HasAuthor
    | HasDepiction
    | HasDocument
    | HasBanner
    | HasPart
    | HasRelation



-- DECODE


{-| -}
fromJson : Decode.Decoder Predicate
fromJson =
    Decode.oneOf
        [ Decode.constant IsAbout "about"
        , Decode.constant HasAuthor "author"
        , Decode.constant HasDepiction "depiction"
        , Decode.constant HasBanner "hasbanner"
        , Decode.constant HasDocument "hasdocument"
        , Decode.constant HasPart "haspart"
        , Decode.constant HasRelation "relation"
        ]


{-| -}
fromString : String -> Maybe Predicate
fromString =
    Result.toMaybe
        << Decode.decodeString fromJson


{-| -}
toString : Predicate -> String
toString predicate =
    case predicate of
        IsAbout ->
            "about"

        HasAuthor ->
            "author"

        HasDepiction ->
            "depiction"

        HasDocument ->
            "hasdocument"

        HasBanner ->
            "hasBanner"

        HasPart ->
            "hasPart"

        HasRelation ->
            "relation"
