module Ginger.Resource.Decode exposing (fromJson)

{-|

@docs decodeList

-}

import Dict exposing (Dict)
import Ginger.Category as Category exposing (Category(..))
import Ginger.Edge as Edge exposing (Edge)
import Ginger.Media as Media exposing (Media)
import Ginger.Predicate as Predicate exposing (Predicate(..))
import Ginger.Resource as Resource exposing (Resource)
import Ginger.Translation as Translation exposing (Translation)
import Iso8601
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import List.NonEmpty as NonEmpty exposing (NonEmpty)
import Time



-- DECODERS


type alias IncludeEdges =
    Bool


{-| -}
fromJson : Decode.Decoder Resource
fromJson =
    decode True


decode : IncludeEdges -> Decode.Decoder Resource
decode includeEdges =
    let
        edgesDecoder =
            if includeEdges then
                decodeEdges

            else
                Decode.succeed Resource.NotFetched
    in
    Decode.succeed Resource
        |> Pipeline.required "id" (Decode.map Resource.Id Decode.int)
        |> Pipeline.required "title" Translation.fromJson
        |> Pipeline.required "body" Translation.fromJson
        |> Pipeline.required "summary" Translation.fromJson
        |> Pipeline.required "path" Decode.string
        |> Pipeline.required "categories" Category.fromJson
        |> Pipeline.required "properties" Decode.value
        |> Pipeline.required "publication_date" Iso8601.decoder
        |> Pipeline.optional "edges" edgesDecoder Resource.NotFetched
        |> Pipeline.optional "media" Media.fromJson Media.empty


decodeEdges : Decode.Decoder Resource.Edges
decodeEdges =
    Decode.map Resource.Edges <|
        Decode.list (Decode.lazy (\_ -> Edge.fromJson decodeEdgeResource))


decodeEdgeResource : Decode.Decoder Resource
decodeEdgeResource =
    Decode.field "resource" (decode False)
