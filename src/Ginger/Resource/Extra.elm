module Ginger.Resource.Extra exposing
    ( Location
    , locationFromJson
    , AuthorName
    , authorName
    , authorNameFromJson
    , EventDate
    , eventDate
    , eventDateFromJson
    )

{-|


# Location

@docs Location
@docs locationFromJson


# Author

@docs AuthorName
@docs authorName
@docs authorNameFromJson


# Event

@docs EventDate
@docs eventDate
@docs eventDateFromJson

-}

import Ginger.Id exposing (ResourceId)
import Ginger.Predicate as Predicate
import Ginger.Resource as Resource exposing (Edges, ResourceWith)
import Ginger.Translation as Translation exposing (Language(..))
import Iso8601
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Time


{-| -}
type alias AuthorName =
    { firstName : String
    , middleName : String
    , lastNamePrefix : String
    , lastName : String
    }


{-| -}
authorName : ResourceWith Edges -> Maybe AuthorName
authorName resource =
    let
        fromProperties edge =
            Result.toMaybe <|
                Decode.decodeValue authorNameFromJson edge.properties
    in
    Maybe.andThen fromProperties <|
        List.head <|
            Resource.objectsOfPredicate Predicate.HasAuthor resource


{-| -}
authorNameFromJson : Decode.Decoder AuthorName
authorNameFromJson =
    Decode.succeed AuthorName
        |> Pipeline.optional "name_first" Decode.string ""
        |> Pipeline.optional "name_middle" Decode.string ""
        |> Pipeline.optional "name_surname_prefix" Decode.string ""
        |> Pipeline.optional "name_surname" Decode.string ""


{-| -}
type alias EventDate =
    { dateStart : Maybe Time.Posix
    , dateEnd : Maybe Time.Posix
    }


{-| -}
eventDate : ResourceWith a -> Maybe EventDate
eventDate resource =
    Result.toMaybe <|
        Decode.decodeValue eventDateFromJson
            resource.properties


{-| -}
eventDateFromJson : Decode.Decoder EventDate
eventDateFromJson =
    Decode.succeed EventDate
        |> Pipeline.optional "date_start" (Decode.maybe Iso8601.decoder) Nothing
        |> Pipeline.optional "date_end" (Decode.maybe Iso8601.decoder) Nothing


{-| -}
type alias Location =
    { id : ResourceId
    , lat : Float
    , lng : Float
    }


{-| -}
locationFromJson : Decode.Decoder Location
locationFromJson =
    Decode.succeed Location
        |> Pipeline.required "id" Ginger.Id.fromJson
        |> Pipeline.required "lat" Decode.float
        |> Pipeline.required "lng" Decode.float
