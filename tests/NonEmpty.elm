module NonEmpty exposing (suite)

import Expect exposing (Expectation)
import Json.Decode as Decode
import Json.Encode as Encode
import List.NonEmpty as NonEmpty exposing (NonEmpty)
import Test exposing (..)


suite : Test
suite =
    describe "The List.NonEmpty module"
        [ test "Return the first item in the list" <|
            \_ ->
                Expect.equal "jimi" <|
                    NonEmpty.head <|
                        NonEmpty.fromList "jimi" [ "bb", "albert" ]
        , test "Return the tail of the list" <|
            \_ ->
                Expect.equal [ "bb", "albert" ] <|
                    NonEmpty.tail <|
                        NonEmpty.fromList "jimi" [ "bb", "albert" ]
        , test "Apply a function to all items of the list" <|
            \_ ->
                Expect.equal [ "jimi rocks", "bb rocks", "albert rocks" ] <|
                    NonEmpty.toList <|
                        NonEmpty.map (\x -> x ++ " rocks") <|
                            NonEmpty.fromList "jimi" [ "bb", "albert" ]
        , test "Reverse the list" <|
            \_ ->
                Expect.equal [ "albert", "bb", "jimi" ] <|
                    NonEmpty.toList <|
                        NonEmpty.reverse <|
                            NonEmpty.fromList "jimi" [ "bb", "albert" ]
        , test "Decode a JSON list" <|
            \_ ->
                Expect.equal (Result.Ok <| NonEmpty.fromList "jimi" [ "bb", "albert" ]) <|
                    Decode.decodeString (NonEmpty.fromJson Decode.string) json
        ]


json : String
json =
    Encode.encode 0 <|
        Encode.list Encode.string [ "jimi", "bb", "albert" ]
