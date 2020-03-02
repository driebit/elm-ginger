module Ginger.Resource exposing
    ( ResourceWith
    , Edges
    , Edge
    , Resource
    , Block
    , BlockType(..)
    , getCategory
    , getCategories
    , getDepiction
    , getDepictions
    , objectsOfPredicate
    , fromJsonWithEdges
    , fromJsonWithoutEdges
    )

{-|


# Definitions

@docs ResourceWith

@docs Edges
@docs Edge
@docs Resource
@docs Block
@docs BlockType


# Access data

@docs getCategory
@docs getCategories
@docs getDepiction
@docs getDepictions
@docs objectsOfPredicate


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


{-| An Elm representation of a Ginger resource.

Note the `a` in the record definition, this an extensible record.
This means it includes _at least_ all of these fields but may have others
as well. This lets us reason about whether the edges are included in the data,
compile time. The Ginger REST API includes edges nested only one level deep,
but since the edges are also resources we can re-use this datatype like
`ResourceWith {}`. This tells use there are _no_ other fields besides the ones here.

So you'll see this used in function signatures like:

    ResourceWith Edges -- has edges

    ResourceWith {} -- does not have the edges

    ResourceWith a -- might have them but the code that's using this doesn't really care

_Note: the `ResourceWith {}` might actually have edges, they are just not fetched._

-}
type alias ResourceWith a =
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


{-| The record we use to extend `ResourceWith a`.

You can render a list of resource depictions like so:

    viewDepictions : ResourceWith Edges -> List (Html msg)
    viewDepictions resource =
        List.map viewImage <|
            depictions Media.Medium resource

This next example won't compile because you need a `ResourceWith Edges`
and this signature indicates they are missing.

    viewDepictions : ResourceWith {} -> List (Html msg)
    viewDepictions resource =
        List.map viewImage <|
            depictions Media.Medium resource

-}
type alias Edges =
    { edges : List Edge }


{-| A connection to a resource named by `Predicate`
-}
type alias Edge =
    { predicate : Predicate
    , resource : ResourceWith {}
    }


{-| Alias for `ResourceWith Edges`
-}
type alias Resource =
    ResourceWith Edges


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


{-| Return all resources with a given predicate.

The returned resources won't have any edges themselves, indicated by the `{}`
in `ResourceWith {}`.

-}
objectsOfPredicate : Predicate -> { a | edges : List Edge } -> List (ResourceWith {})
objectsOfPredicate predicate resource =
    List.map .resource <|
        List.filter ((==) predicate << .predicate) resource.edges


{-| Get the category of a `ResourceWith`.

Every resource has _one_ category, but can be part of a hierarchy of other
categories. For example `news` is part of `text > article > news`. This function
will always return the `Category` stored with the `ResourceWith`.

-}
getCategory : ResourceWith a -> Category
getCategory =
    List.NonEmpty.head << .category


{-| Get the category including its parents from a `ResourceWith` sorted
from big to small.
-}
getCategories : ResourceWith a -> List Category
getCategories =
    List.reverse << List.NonEmpty.toList << .category


{-| The image url of the `ResourceWith` depiction.

Returns the image url if there is a depiction _and_ the mediaclass exists.

-}
getDepiction : Media.MediaClass -> ResourceWith Edges -> Maybe String
getDepiction mediaClass =
    List.head << getDepictions mediaClass


{-| The image urls of the `ResourceWith` depictions

Returns a list of image urls if there is a depiction _and_ the mediaclass exists.

-}
getDepictions : Media.MediaClass -> ResourceWith Edges -> List String
getDepictions mediaClass resource =
    List.filterMap (Media.imageUrl mediaClass << .media) <|
        objectsOfPredicate Predicate.HasDepiction resource



-- DECODE


{-| Decode a `ResourceWith` that has edges.
-}
fromJsonWithEdges : Decode.Decoder (ResourceWith Edges)
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


{-| Decode a `ResourceWith` that does not have edges.
-}
fromJsonWithoutEdges : Decode.Decoder (ResourceWith {})
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
