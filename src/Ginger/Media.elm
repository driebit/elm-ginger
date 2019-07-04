module Ginger.Media exposing
    ( Media(..)
    , MediaClass(..)
    , VideoData
    , imageUrl
    , videoData
    , imageClassToString
    , empty
    , fromJson
    )

{-|


# Definitions

@docs Media
@docs MediaClass
@docs VideoData


# Build & Query

@docs imageUrl
@docs videoData
@docs imageClassToString
@docs empty


# Decode

@docs fromJson

-}

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline



-- DEFINITIONS


{-| -}
type Media
    = Image (Dict String String)
    | Video VideoData
    | Empty


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


{-| -}
type alias VideoData =
    { embedCode : String
    , width : Int
    , height : Int
    }



-- OTHER


{-| The image url with a given `MediaClass`
-}
imageUrl : MediaClass -> Media -> Maybe String
imageUrl mediaClass media =
    case media of
        Image info ->
            Dict.get (imageClassToString mediaClass) info

        Video _ ->
            Nothing

        Empty ->
            Nothing


{-| The video data.
-}
videoData : Media -> Maybe VideoData
videoData media =
    case media of
        Video data ->
            Just data

        Image _ ->
            Nothing

        Empty ->
            Nothing


{-| -}
imageClassToString : MediaClass -> String
imageClassToString mediaClass =
    case mediaClass of
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


{-| -}
empty : Media
empty =
    Empty



-- DECODE


{-| Decode image and video data
-}
fromJson : Decode.Decoder Media
fromJson =
    let
        imageDecoder =
            Decode.map (Image << Dict.fromList) <|
                Decode.list <|
                    Decode.map2 Tuple.pair
                        (Decode.field "mediaclass" Decode.string)
                        (Decode.field "url" Decode.string)

        videoDecoder =
            Decode.map Video <|
                Decode.map3 VideoData
                    (Decode.field "url" Decode.string)
                    (Decode.field "width" Decode.int)
                    (Decode.field "height" Decode.int)
    in
    Decode.oneOf [ imageDecoder, videoDecoder ]
