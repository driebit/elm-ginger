module Ginger.Resource exposing
    ( Resource
    , Block
    , edges
    , edgesWithPredicate
    , category
    , media
    , depiction
    , fromJson
    )

{-|


# Definitions

@docs Resource

@docs Block


# Query

@docs edges
@docs edgesWithPredicate
@docs category
@docs media
@docs depiction


# Decode

@docs fromJson

-}

import Ginger.Category as Category exposing (Category(..))
import Ginger.Id as Id exposing (Id)
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
type alias Resource =
    { id : Id
    , title : Translation
    , body : Translation
    , summary : Translation
    , path : String
    , category : NonEmpty Category
    , properties : Decode.Value
    , publicationDate : Maybe Time.Posix
    , edges : Edges
    , media : Media
    , blocks : List Block
    }


{-| -}
type Edges
    = NotFetched
    | Edges (List Edge)


{-| A named connection to a resource
-}
type Edge
    = Edge Predicate Resource


{-| -}
type alias Block =
    { body : Translation
    , name : String
    }



-- QUERY


{-| -}
edges : Resource -> Maybe (List Resource)
edges resource =
    case resource.edges of
        NotFetched ->
            Nothing

        Edges xs ->
            Just (List.map (\(Edge _ r) -> r) xs)


{-| -}
edgesWithPredicate : Predicate -> Resource -> Maybe (List Resource)
edgesWithPredicate predicate resource =
    case resource.edges of
        NotFetched ->
            Nothing

        Edges xs ->
            let
                filter (Edge p r) =
                    if p == predicate then
                        Just r

                    else
                        Nothing
            in
            Just (List.filterMap filter xs)


{-| -}
category : Resource -> Category
category =
    List.NonEmpty.head << .category


{-| -}
media : Predicate -> Media.MediaClass -> Resource -> Maybe (List String)
media predicate imageClass resource =
    Maybe.map (List.filterMap (Media.url imageClass << .media)) <|
        edgesWithPredicate predicate resource


{-| -}
depiction : Media.MediaClass -> Resource -> Maybe String
depiction imageClass resource =
    Maybe.andThen List.head <|
        media Predicate.HasDepiction imageClass resource



-- DECODE


type alias IncludeEdges =
    Bool


{-| -}
fromJson : Decode.Decoder Resource
fromJson =
    decodeResource True


decodeResource : IncludeEdges -> Decode.Decoder Resource
decodeResource includeEdges =
    let
        edgesDecoder =
            if includeEdges then
                decodeEdges

            else
                Decode.succeed NotFetched
    in
    Decode.succeed Resource
        |> Pipeline.required "id" Id.fromJson
        |> Pipeline.required "title" Translation.fromJson
        |> Pipeline.required "body" Translation.fromJson
        |> Pipeline.required "summary" Translation.fromJson
        |> Pipeline.required "path" Decode.string
        |> Pipeline.required "categories" Category.fromJson
        |> Pipeline.required "properties" Decode.value
        |> Pipeline.required "publication_date" (Decode.maybe Iso8601.decoder)
        |> Pipeline.optional "edges" edgesDecoder NotFetched
        |> Pipeline.optional "media" Media.fromJson Media.empty
        |> Pipeline.required "blocks" (Decode.list decodeBlock)


decodeEdges : Decode.Decoder Edges
decodeEdges =
    Decode.map Edges <|
        Decode.list (Decode.lazy (\_ -> decodeEdge))


decodeEdge : Decode.Decoder Edge
decodeEdge =
    Decode.succeed Edge
        |> Pipeline.required "predicate_name" Predicate.fromJson
        |> Pipeline.required "resource" (decodeResource False)


decodeBlock : Decode.Decoder Block
decodeBlock =
    Decode.succeed Block
        |> Pipeline.required "body" Translation.fromJson
        |> Pipeline.required "name" Decode.string
