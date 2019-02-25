module Identity exposing (suite)

import Expect exposing (Expectation)
import Ginger.Auth as Auth exposing (Identity)
import Iso8601
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)
import Time


suite : Test
suite =
    describe "The Auth module"
        [ test "Decode Identity" <|
            \_ ->
                Expect.equal (Ok identity) <|
                    Decode.decodeString Identity.fromJson json
        ]


identity : Identity
identity =
    { id = 1
    , resourceId = 1
    , method = Identity.Ginger
    , key = "jimi"
    , unique = True
    , verified = True
    , created = Time.millisToPosix 1
    , modified = Time.millisToPosix 1
    , lastVisit = Time.millisToPosix 1
    }


json : String
json =
    Encode.encode 0 <|
        Encode.object
            [ ( "id", Encode.int 1 )
            , ( "rsc_id", Encode.int 1 )
            , ( "type", Encode.string "username_pw" )
            , ( "key", Encode.string "jimi" )
            , ( "is_unique", Encode.bool True )
            , ( "is_verified", Encode.bool True )
            , ( "created", Iso8601.encode (Time.millisToPosix 1) )
            , ( "modified", Iso8601.encode (Time.millisToPosix 1) )
            , ( "visited", Iso8601.encode (Time.millisToPosix 1) )
            ]
