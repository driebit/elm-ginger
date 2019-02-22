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
    | Custom String



-- DECODE


{-| -}
fromJson : Decode.Decoder Predicate
fromJson =
    Decode.map fromString Decode.string


{-| -}
fromString : String -> Predicate
fromString predicate =
    case predicate of
        "about" ->
            IsAbout

        "author" ->
            HasAuthor

        "depiction" ->
            HasDepiction

        "hasbanner" ->
            HasBanner

        "hasdocument" ->
            HasDocument

        "haspart" ->
            HasPart

        "relation" ->
            HasRelation

        x ->
            Custom x


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

        Custom x ->
            x
