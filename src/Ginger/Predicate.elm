module Ginger.Predicate exposing
    ( Predicate(..)
    , fromString
    , toString
    , fromJson
    )

{-|


# Definition

@docs Predicate


# Conversions

@docs fromString
@docs toString


# Decode

@docs fromJson

-}

import Json.Decode as Decode
import List.NonEmpty exposing (NonEmpty)



-- DEFINITIONS


{-| -}
type Predicate
    = IsAbout
    | HasAuthor
    | HasDepiction
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

        HasBanner ->
            "hasBanner"

        HasPart ->
            "hasPart"

        HasRelation ->
            "relation"

        Custom x ->
            x
