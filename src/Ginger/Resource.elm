module Ginger.Resource exposing
    ( Resource
    , WithEdges
    , Edge
    , Block
    , BlockType(..)
    , edgesWithPredicate
    , category
    , depiction
    , depictions
    , fromJsonWithEdges
    , fromJsonWithoutEdges
    )

{-|


# Definitions

@docs Resource

@docs WithEdges
@docs Edge
@docs Block
@docs BlockType


# Query

@docs edgesWithPredicate
@docs category
@docs depiction
@docs depictions


# Decode

@docs fromJsonWithEdges
@docs fromJsonWithoutEdges

-}

import Ginger.Category as Category exposing (Category(..))
import Ginger.Id as Id exposing (ResourceId)
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
type alias Resource a =
    { a
        | id : ResourceId
        , title : Translation
        , body : Translation
        , subtitle : Translation
        , summary : Translation
        , path : String
        , category : NonEmpty Category
        , properties : Decode.Value
        , publicationDate : Maybe Time.Posix
        , media : Media
        , blocks : List Block
    }


{-| -}
type alias WithEdges =
    { edges : List Edge }


{-| A named connection to a resource. The `Resource` doesn't
have any edges because the Ginger rest api only includes edges
one level deep.
-}
type alias Edge =
    { predicate : Predicate
    , resource : Resource {}
    }


{-| -}
type alias Block =
    { body : Translation
    , name : String
    , type_ : BlockType
    , relatedRscId : Maybe ResourceId
    , properties : Decode.Value
    }


{-| -}
type BlockType
    = Text
    | Header
    | Page
    | Custom String



-- QUERY


{-| -}
edgesWithPredicate : Predicate -> Resource WithEdges -> List (Resource {})
edgesWithPredicate predicate resource =
    List.map .resource <|
        List.filter ((==) predicate << .predicate) resource.edges


{-| -}
category : Resource a -> Category
category =
    List.NonEmpty.head << .category


{-| -}
depiction : Media.MediaClass -> Resource WithEdges -> Maybe String
depiction mediaClass =
    List.head << depictions mediaClass


{-| -}
depictions : Media.MediaClass -> Resource WithEdges -> List String
depictions mediaClass resource =
    List.filterMap (Media.imageUrl mediaClass << .media) <|
        edgesWithPredicate Predicate.HasDepiction resource



-- DECODE


{-| -}
fromJsonWithEdges : Decode.Decoder (Resource WithEdges)
fromJsonWithEdges =
    let
        resourceWithEdges a b c d e f g h i j k l =
            { id = a
            , title = b
            , body = c
            , subtitle = d
            , summary = e
            , path = f
            , category = g
            , properties = h
            , publicationDate = i
            , media = j
            , blocks = k
            , edges = l
            }
    in
    Decode.succeed resourceWithEdges
        |> Pipeline.required "id" Id.fromJson
        |> Pipeline.required "title" Translation.fromJson
        |> Pipeline.required "body" Translation.fromJson
        |> Pipeline.required "subtitle" Translation.fromJson
        |> Pipeline.required "summary" Translation.fromJson
        |> Pipeline.required "path" Decode.string
        |> Pipeline.required "categories" Category.fromJson
        |> Pipeline.required "properties" Decode.value
        |> Pipeline.required "publication_date" (Decode.maybe Iso8601.decoder)
        |> Pipeline.optional "media" Media.fromJson Media.empty
        |> Pipeline.required "blocks" (Decode.list decodeBlock)
        |> Pipeline.optional "edges" decodeEdges []


{-| -}
fromJsonWithoutEdges : Decode.Decoder (Resource {})
fromJsonWithoutEdges =
    let
        resourceWithoutEdges a b c d e f g h i j k =
            { id = a
            , title = b
            , body = c
            , subtitle = d
            , summary = e
            , path = f
            , category = g
            , properties = h
            , publicationDate = i
            , media = j
            , blocks = k
            }
    in
    Decode.succeed resourceWithoutEdges
        |> Pipeline.required "id" Id.fromJson
        |> Pipeline.required "title" Translation.fromJson
        |> Pipeline.required "body" Translation.fromJson
        |> Pipeline.required "subtitle" Translation.fromJson
        |> Pipeline.required "summary" Translation.fromJson
        |> Pipeline.required "path" Decode.string
        |> Pipeline.required "categories" Category.fromJson
        |> Pipeline.required "properties" Decode.value
        |> Pipeline.required "publication_date" (Decode.maybe Iso8601.decoder)
        |> Pipeline.optional "media" Media.fromJson Media.empty
        |> Pipeline.required "blocks" (Decode.list decodeBlock)


decodeEdges : Decode.Decoder (List Edge)
decodeEdges =
    Decode.list decodeEdge


decodeEdge : Decode.Decoder Edge
decodeEdge =
    Decode.succeed Edge
        |> Pipeline.required "predicate_name" Predicate.fromJson
        |> Pipeline.required "resource" fromJsonWithoutEdges


decodeBlock : Decode.Decoder Block
decodeBlock =
    Decode.succeed Block
        |> Pipeline.required "body" Translation.fromJson
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "type" decodeBlockType
        |> Pipeline.required "rsc_id" (Decode.maybe Id.fromJson)
        |> Pipeline.required "properties" Decode.value


decodeBlockType : Decode.Decoder BlockType
decodeBlockType =
    let
        toBlockType type_ =
            case type_ of
                "page" ->
                    Page

                "text" ->
                    Text

                "header" ->
                    Header

                other ->
                    Custom other
    in
    Decode.map toBlockType Decode.string
