module Ginger.Edge exposing
    ( Edge
    , const
    , fromJson
    , unwrap
    , withPredicate
    )

{-|

@docs Edge
@docs const
@docs fromJson
@docs unwrap
@docs withPredicate

-}

import Ginger.Predicate as Predicate exposing (Predicate)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


{-| A named connection to a resource
-}
type Edge resource
    = Edge Predicate resource


{-| Decode an edge from a Ginger.Rest response
-}
fromJson : Decode.Decoder resource -> Decode.Decoder (Edge resource)
fromJson decoder =
    Decode.succeed Edge
        |> Pipeline.required "predicate_name" Predicate.fromJson
        |> Pipeline.custom decoder


{-| Construct Edge from a Ginger.Predicate and resource
-}
const : Predicate -> resource -> Edge resource
const =
    Edge


{-| Get `resource` wrapped in the Edge type
-}
unwrap : Edge resource -> resource
unwrap (Edge _ resource) =
    resource


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
