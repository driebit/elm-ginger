module Resource exposing (suite)

import Expect exposing (Expectation)
import Ginger.Category as Category exposing (Category(..))
import Ginger.Edge as Edge exposing (Edge)
import Ginger.Media as Media exposing (Media)
import Ginger.Predicate as Predicate exposing (Predicate(..))
import Ginger.Resource as Resource exposing (Resource)
import Ginger.Translation as Translation exposing (Language(..))
import Json.Encode as Encode
import List.NonEmpty as NonEmpty exposing (NonEmpty)
import Test exposing (..)
import Time


suite : Test
suite =
    describe "The Ginger Resource module"
        [ test "Returns list of urls from edge with specific predicate" <|
            \_ ->
                Expect.equal [ "http://image1.jpg", "http://image2.jpg" ] <|
                    Resource.media Predicate.HasDepiction Media.Avatar (resource True "")
        ]


resource : Bool -> String -> Resource
resource withEdges imageUrl =
    let
        edges =
            if withEdges then
                Resource.Edges
                    [ Edge.wrap Predicate.HasDepiction (resource False "http://image1.jpg")
                    , Edge.wrap Predicate.HasDepiction (resource False "http://image2.jpg")
                    ]

            else
                Resource.NotFetched
    in
    { id = Resource.Id 1
    , title = Translation.fromList [ ( EN, "" ) ]
    , body = Translation.fromList [ ( EN, "" ) ]
    , summary = Translation.fromList [ ( EN, "" ) ]
    , publicationDate = Time.millisToPosix 1
    , path = ""
    , category = NonEmpty.fromList Category.Text []
    , properties = Encode.null
    , edges = edges
    , media =
        Media.fromList
            [ ( Media.Avatar, imageUrl )
            , ( Media.Small, "http://image3.jpg" )
            ]
    }
