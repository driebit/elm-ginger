module Ginger.Resource exposing
    ( Edges(..)
    , Id(..)
    , Resource
    , category
    , edges
    , media
    )

{-|


# Definitions

@docs Edges
@docs Id
@docs Resource


# Query

@docs category
@docs edges

-}

import Ginger.Category as Category exposing (Category(..))
import Ginger.Edge as Edge exposing (Edge)
import Ginger.Media as Media exposing (Media)
import Ginger.Predicate as Predicate exposing (Predicate(..))
import Ginger.Translation as Translation exposing (Translation)
import Json.Decode as Decode
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



-- MEDIA


{-| -}
media : Predicate -> Media.ImageClass -> Resource -> List String
media predicate imageClass resource =
    case resource.edges of
        Edges xs ->
            List.filterMap (Media.url imageClass << .media) <|
                Edge.withPredicate predicate xs

        NotFetched ->
            []
