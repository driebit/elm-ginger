module Ginger.Media exposing
    ( Media
    , MediaClass(..)
    , empty
    , url
    , imageClassToString
    , fromJson
    )

{-|


# Definitions

@docs Media
@docs MediaClass


# Build & Query

@docs empty
@docs url
@docs imageClassToString


# Decode

@docs fromJson

-}

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline



-- DEFINITIONS


{-| -}
type Media
    = Media (Dict String String)


{-| -}
type MediaClass
    = Avatar
    | Thumbnail
    | Card
    | Small
    | Medium
    | Large
    | Cinemascope
    | Custom String



-- DECODE


{-| -}
fromJson : Decode.Decoder Media
fromJson =
    let
        decoder =
            Decode.succeed Tuple.pair
                |> Pipeline.required "mediaclass" Decode.string
                |> Pipeline.required "url" Decode.string
    in
    Decode.map (Media << Dict.fromList) <|
        Decode.list decoder



-- OTHER


{-| -}
empty : Media
empty =
    Media Dict.empty


{-| -}
url : MediaClass -> Media -> Maybe String
url imageClass (Media media) =
    Dict.get (imageClassToString imageClass) media


{-| -}
imageClassToString : MediaClass -> String
imageClassToString imageClass =
    case imageClass of
        Avatar ->
            "avatar"

        Thumbnail ->
            "thumbnail"

        Card ->
            "card"

        Small ->
            "small"

        Medium ->
            "medium"

        Large ->
            "large"

        Cinemascope ->
            "cinemascope"

        Custom custom ->
            custom
