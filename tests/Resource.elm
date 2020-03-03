module Resource exposing (suite)

import Expect exposing (Expectation)
import Ginger.Category as Category
import Ginger.Resource as Resource
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)


suite : Test
suite =
    describe "The Ginger.Resource module"
        [ test "Return all categories sorted" <|
            \_ ->
                Expect.equal (Ok [ Category.Text, Category.News ]) <|
                    Result.map Resource.getCategories <|
                        Decode.decodeString Resource.fromJsonWithEdges resource
        ]


resource : String
resource =
    Encode.encode 0 <|
        Encode.object
            [ ( "id", Encode.int 1 )
            , ( "path", Encode.string "" )
            , ( "blocks", Encode.list Encode.string [] )
            , ( "edges", Encode.list Encode.string [] )
            , ( "body", Encode.object [ ( "nl", Encode.string "" ) ] )
            , ( "title", Encode.object [ ( "nl", Encode.string "" ) ] )
            , ( "subtitle", Encode.object [ ( "nl", Encode.string "" ) ] )
            , ( "summary", Encode.object [ ( "nl", Encode.string "" ) ] )
            , ( "publication_date", Encode.string "2019-10-02T12:51:00Z" )
            , ( "properties", Encode.null )
            , ( "categories", Encode.list Encode.string [ "text", "news" ] )
            ]
