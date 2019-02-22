module Media exposing (suite)

import Expect exposing (Expectation)
import Ginger.Media as Media exposing (Media)
import Ginger.Predicate as Predicate exposing (Predicate(..))
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)


suite : Test
suite =
    describe "The Ginger Media module"
        -- [ test "Get url of media with imageclass" <|
        --     \_ ->
        --         Expect.equal (Just "http://image.jpg") <|
        --             Media.url Media.Small <|
        Media.fromList
        [ ( Media.Small, "http://image.jpg" ) ]
        [ test "Decode Json string in to Media type" <|
            \_ ->
                Expect.equal
                    media
                    (Result.mapError Decode.errorToString <|
                        Decode.decodeString Media.fromJson json
                    )
        ]


json : String
json =
    let
        item ( x, y ) =
            Encode.object
                [ ( "mediaclass", Encode.string x )
                , ( "url", Encode.string y )
                ]
    in
    Encode.encode 0 <|
        Encode.list item
            [ ( "avatar", "http://image.jpg" )
            , ( "small", "http://image.jpg" )
            ]


media : Result String Media
media =
    Result.Ok <|
        Media.fromList
            [ ( Media.Avatar, "http://image.jpg" )
            , ( Media.Small, "http://image.jpg" )
            ]
