module Ginger.Resource exposing
    ( Resource
    , Id(..)
    , Edges(..)
    , category
    , edges
    , media
    , fromJson
    )

{-|


# Definitions

@docs Resource
@docs Id
@docs Edges


# Query

@docs category
@docs edges
@docs media


# Decode

@docs fromJson

-}

import Dict exposing (Dict)
import Ginger.Category as Category exposing (Category(..))
import Ginger.Edge as Edge exposing (Edge)
import Ginger.Media as Media exposing (Media)
import Ginger.Predicate as Predicate exposing (Predicate(..))
import Ginger.Translation as Translation exposing (Translation)
import Iso8601
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import List.NonEmpty exposing (NonEmpty)
import Time



-- DEFINITIONS


{-| -}
type Id
    = Id Int


{-| -}
type alias Resource =
    { id : Id
    , title : Translation
    , body : Translation
    , summary : Translation
    , path : String
    , category : NonEmpty Category
    , properties : Decode.Value
    , publicationDate : Time.Posix
    , edges : Edges
    , media : Media
    }


{-| -}
type Edges
    = NotFetched
    | Edges (List (Edge Resource))



-- QUERY


{-| -}
edges : Resource -> Maybe (List Resource)
edges resource =
    case resource.edges of
        NotFetched ->
            Nothing

        Edges xs ->
            Just (List.map Edge.unwrap xs)


{-| -}
category : Resource -> Category
category =
    List.NonEmpty.head << .category


{-| -}
media : Predicate -> Media.ImageClass -> Resource -> List String
media predicate imageClass resource =
    case resource.edges of
        Edges xs ->
            List.filterMap (Media.url imageClass << .media) <|
                Edge.withPredicate predicate xs

        NotFetched ->
            []



-- DECODE


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
                Decode.succeed NotFetched
    in
    Decode.succeed Resource
        |> Pipeline.required "id" (Decode.map Id Decode.int)
        |> Pipeline.required "title" Translation.fromJson
        |> Pipeline.required "body" Translation.fromJson
        |> Pipeline.required "summary" Translation.fromJson
        |> Pipeline.required "path" Decode.string
        |> Pipeline.required "categories" Category.fromJson
        |> Pipeline.required "properties" Decode.value
        |> Pipeline.required "publication_date" Iso8601.decoder
        |> Pipeline.optional "edges" edgesDecoder NotFetched
        |> Pipeline.optional "media" Media.fromJson Media.empty


decodeEdges : Decode.Decoder Edges
decodeEdges =
    Decode.map Edges <|
        Decode.list (Decode.lazy (\_ -> Edge.fromJson decodeEdgeResource))


decodeEdgeResource : Decode.Decoder Resource
decodeEdgeResource =
    Decode.field "resource" (decode False)
