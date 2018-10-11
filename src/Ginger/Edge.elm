module Ginger.Edge exposing
    ( Edge
    , wrap
    , unwrap
    , withPredicate
    , fromJson
    )

{-|


# Definition

@docs Edge


# Wrapping

@docs wrap
@docs unwrap


# Query

@docs withPredicate


# Decode

@docs fromJson

-}

import Ginger.Predicate as Predicate exposing (Predicate)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline



-- DEFINITIONS


{-| A named connection to a resource
-}
type Edge resource
    = Edge Predicate resource



-- WRAPPING


{-| Construct an Edge from a Ginger.Predicate and resource
-}
wrap : Predicate -> resource -> Edge resource
wrap =
    Edge


{-| Get the `resource` wrapped in the Edge type
-}
unwrap : Edge resource -> resource
unwrap (Edge _ resource) =
    resource



-- QUERY


{-| Get all `resource` with a predicate
-}
withPredicate : Predicate -> List (Edge resource) -> List resource
withPredicate predicate edges =
    let
        filter (Edge p resource) =
            if p == predicate then
                Just resource

            else
                Nothing
    in
    List.filterMap filter edges



-- DECODE


{-| Decode an edge from a Ginger.Rest response
-}
fromJson : Decode.Decoder resource -> Decode.Decoder (Edge resource)
fromJson decoder =
    Decode.succeed Edge
        |> Pipeline.required "predicate_name" Predicate.fromJson
        |> Pipeline.custom decoder
