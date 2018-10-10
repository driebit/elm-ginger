module Ginger.Predicate exposing
    ( Predicate(..)
    , fromJson
    , fromString
    , toString
    )

import Json.Decode as Decode



-- DEFINITIONS


{-| -}
type Predicate
    = About
    | Author
    | Depiction
    | HasBanner
    | HasPart
    | Relation
    | Custom String



-- DECODE


fromJson : Decode.Decoder Predicate
fromJson =
    Decode.map fromString Decode.string


{-| -}
fromString : String -> Predicate
fromString predicate =
    case predicate of
        "about" ->
            About

        "author" ->
            Author

        "depiction" ->
            Depiction

        "hasbanner" ->
            HasBanner

        "haspart" ->
            HasPart

        "relation" ->
            Relation

        x ->
            Custom x


{-| -}
toString : Predicate -> String
toString predicate =
    case predicate of
        About ->
            "about"

        Author ->
            "author"

        Depiction ->
            "depiction"

        HasBanner ->
            "hasBanner"

        HasPart ->
            "hasPart"

        Relation ->
            "relation"

        Custom x ->
            x
