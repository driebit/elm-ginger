module Resource.Decode exposing (suite)

import Dict
import Expect exposing (Expectation)
import Ginger.Category as Category exposing (Category(..))
import Ginger.Edge as Edge exposing (Edge)
import Ginger.Media as Media exposing (Media)
import Ginger.Predicate as Predicate exposing (Predicate(..))
import Ginger.Resource as Resource exposing (Resource)
import Ginger.Translation as Translation exposing (Language(..))
import Iso8601
import Json.Decode as Decode
import Json.Encode as Encode
import List.NonEmpty as NonEmpty exposing (NonEmpty)
import Test exposing (..)
import Time


suite : Test
suite =
    describe "The Ginger Decode module"
        [ test "Decodes a JSON string into a Ginger.Resource record" <|
            \_ ->
                Expect.equal
                    resourceList
                    (Result.mapError Decode.errorToString <|
                        Decode.decodeString Ginger.Resource.fromJson json
                    )
        ]


json : String
json =
    """{
    "body": {
        "en": "Hello"
    },
    "categories": [
        "text"
    ],
    "id": 1,
    "path": "/page/341/text",
    "properties": null,
    "publication_date": "2018-06-12T12:48:08Z",
    "summary": {
        "en": "World"
    },
    "title": {
        "nl": "Greeting"
    },
    "edges": [
        {
            "predicate_name": "about",
            "resource": {
                "body": {
                    "en": "Hello"
                },
                "categories": [
                    "text"
                ],
                "id": 1,
                "path": "/page/341/text",
                "properties": null,
                "publication_date": "2018-06-12T12:48:08Z",
                "summary": {
                    "en": "World"
                },
                "title": {
                    "nl": "Greeting"
                },
                "media": [
                    {
                        "mediaclass": "avatar",
                        "url": "http://image.jpg"
                    },
                    {
                        "mediaclass": "small",
                        "url": "http://image.jpg"
                    }
                ]
            }
        }
    ],
    "media": [
        {
            "mediaclass": "avatar",
            "url": "http://image.jpg"
        },
        {
            "mediaclass": "small",
            "url": "http://image.jpg"
        }
    ]
}"""


resourceList : Result String Resource
resourceList =
    Iso8601.toTime "2018-06-12T12:48:08Z"
        |> Result.mapError (always "Error")
        |> Result.map (resource True)


resource : Bool -> Time.Posix -> Resource
resource withEdges posix =
    let
        edges =
            if withEdges then
                Resource.Edges
                    [ Edge.const Predicate.About (resource False posix) ]

            else
                Resource.NotFetched
    in
    { id = Resource.Id 1
    , title = Translation.fromList [ ( NL, "Greeting" ) ]
    , body = Translation.fromList [ ( EN, "Hello" ) ]
    , summary = Translation.fromList [ ( EN, "World" ) ]
    , publicationDate = posix
    , path = "/page/341/text"
    , category = NonEmpty.fromList Category.Text []
    , properties = Encode.null
    , edges = edges
    , media =
        Media.fromList
            [ ( Media.Avatar, "http://image.jpg" )
            , ( Media.Small, "http://image.jpg" )
            ]
    }
