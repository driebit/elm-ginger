module List.NonEmpty exposing
    ( NonEmpty
    , fromJson
    , fromList
    , head
    , map
    , reverse
    , tail
    , toList
    )

import Json.Decode as Decode



-- DEFINITION


type NonEmpty a
    = NonEmpty a (List a)



-- BASIC FUNCTIONS


fromList : a -> List a -> NonEmpty a
fromList x xs =
    NonEmpty x xs


toList : NonEmpty a -> List a
toList (NonEmpty x xs) =
    x :: xs


head : NonEmpty a -> a
head (NonEmpty x _) =
    x


tail : NonEmpty a -> List a
tail (NonEmpty _ xs) =
    xs


map : (a -> b) -> NonEmpty a -> NonEmpty b
map func (NonEmpty x xs) =
    NonEmpty (func x) (List.map func xs)


reverse : NonEmpty a -> NonEmpty a
reverse ((NonEmpty x xs) as nonEmpty) =
    case List.reverse (x :: xs) of
        [] ->
            nonEmpty

        b :: rest ->
            NonEmpty b rest



-- DECODE


fromJson : Decode.Decoder a -> Decode.Decoder (NonEmpty a)
fromJson decoder =
    Decode.list decoder
        |> Decode.andThen checkList


checkList : List a -> Decode.Decoder (NonEmpty a)
checkList list =
    case list of
        [] ->
            Decode.fail "An array with one or more elements."

        x :: xs ->
            Decode.succeed (NonEmpty x xs)
