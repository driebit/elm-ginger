module Ginger.Category exposing
    ( Category(..)
    , fromJson
    , fromString
    , toString
    )

{-|

@docs Category
@docs fromJson
@docs fromString
@docs toString

-}

import Json.Decode as Decode
import List.NonEmpty exposing (NonEmpty)



-- DEFINITIONS


{-| -}
type Category
    = Text
    | Person
    | Location
    | Website
    | Event
    | Artifact
    | Media
    | Image
    | Video
    | Audio
    | Document
    | Collection
    | Meta
    | Agenda
    | Article
    | News
    | Custom String



-- DECODE


{-| -}
fromJson : Decode.Decoder (NonEmpty Category)
fromJson =
    Decode.map (List.NonEmpty.reverse << List.NonEmpty.map fromString) <|
        List.NonEmpty.fromJson Decode.string


{-| -}
fromString : String -> Category
fromString category =
    case category of
        "text" ->
            Text

        "person" ->
            Person

        "location" ->
            Location

        "website" ->
            Website

        "event" ->
            Event

        "artifact" ->
            Artifact

        "media" ->
            Media

        "image" ->
            Image

        "video" ->
            Video

        "audio" ->
            Audio

        "document" ->
            Document

        "collection" ->
            Collection

        "meta" ->
            Meta

        "agenda" ->
            Agenda

        "article" ->
            Article

        "news" ->
            News

        custom ->
            Custom custom


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

        Custom custom ->
            custom
