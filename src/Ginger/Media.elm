module Ginger.Media exposing
    ( ImageClass(..)
    , Media
    , empty
    , fromJson
    , fromList
    , url
    )

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline



-- DEFINITIONS


type Media
    = Media (Dict String String)


type ImageClass
    = Avatar
    | Thumbnail
    | Small
    | Medium
    | Large
    | Custom String



-- DECODE


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


empty : Media
empty =
    Media Dict.empty


fromList : List ( ImageClass, String ) -> Media
fromList =
    Media << Dict.fromList << List.map (Tuple.mapFirst imageClassToString)


url : ImageClass -> Media -> Maybe String
url imageClass (Media media) =
    Dict.get (imageClassToString imageClass) media


imageClassToString : ImageClass -> String
imageClassToString imageClass =
    case imageClass of
        Avatar ->
            "avatar"

        Thumbnail ->
            "thumbnail"

        Small ->
            "small"

        Medium ->
            "medium"

        Large ->
            "large"

        Custom custom ->
            custom
