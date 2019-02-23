module Ginger.Resource.Extra exposing (AuthorName)

{-| -}

import Ginger.Predicate as Predicate
import Ginger.Resource as Resource exposing (Resource)
import Ginger.Translation as Translation exposing (Language(..))
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


{-| -}
type alias AuthorName =
    { firstName : String
    , middleName : String
    , lastNamePrefix : String
    , lastName : String
    }


authorName : Resource -> Maybe AuthorName
authorName resource =
    let
        fromProperties edge =
            Result.toMaybe <|
                Decode.decodeValue decodeAuthorName edge.properties
    in
    Maybe.andThen fromProperties <|
        Maybe.andThen List.head <|
            Resource.edgesWithPredicate Predicate.HasAuthor resource



-- DECODER


decodeAuthorName : Decode.Decoder AuthorName
decodeAuthorName =
    Decode.succeed AuthorName
        |> Pipeline.optional "name_first" Decode.string ""
        |> Pipeline.optional "name_middle" Decode.string ""
        |> Pipeline.optional "name_surname_prefix" Decode.string ""
        |> Pipeline.optional "name_surname" Decode.string ""
