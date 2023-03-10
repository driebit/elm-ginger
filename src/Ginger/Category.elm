module Ginger.Category exposing
    ( Category(..)
    , toString
    , fromString
    , fromJson
    )

{-|


# Definition

@docs Category


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
type Category
    = Agenda
    | Article
    | Artifact
    | Audio
    | Collection
    | Document
    | Event
    | Image
    | Location
    | Media
    | Meta
    | News
    | Person
    | Text
    | Video
    | Website



-- DECODE


{-| -}
fromJson : Decode.Decoder Category
fromJson =
    Decode.oneOf <|
        [ Decode.constant Text "text"
        , Decode.constant Person "person"
        , Decode.constant Location "location"
        , Decode.constant Website "website"
        , Decode.constant Event "event"
        , Decode.constant Artifact "artifact"
        , Decode.constant Media "media"
        , Decode.constant Image "image"
        , Decode.constant Video "video"
        , Decode.constant Audio "audio"
        , Decode.constant Document "document"
        , Decode.constant Collection "collection"
        , Decode.constant Meta "meta"
        , Decode.constant Agenda "agenda"
        , Decode.constant Article "article"
        , Decode.constant News "news"
        ]


{-| -}
fromString : String -> Maybe Category
fromString =
    Result.toMaybe
        << Decode.decodeString fromJson


{-| -}
toString : Category -> String
toString category =
    case category of
        Text ->
            "text"

        Person ->
            "person"

        Location ->
            "location"

        Website ->
            "website"

        Event ->
            "event"

        Artifact ->
            "artifact"

        Media ->
            "media"

        Image ->
            "image"

        Video ->
            "video"

        Audio ->
            "audio"

        Document ->
            "document"

        Collection ->
            "collection"

        Meta ->
            "meta"

        Agenda ->
            "agenda"

        Article ->
            "article"

        News ->
            "news"
