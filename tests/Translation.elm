module Translation exposing (suite)

import Expect exposing (Expectation)
import Ginger.Translation as Translation exposing (Language(..), Translation)
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)


suite : Test
suite =
    describe "The Ginger Translation module"
        [ test "Returns a translated string" <|
            \_ ->
                Expect.equal "Hello" <|
                    Translation.toString EN translation
        , test "Returns an fallback string" <|
            \_ ->
                Expect.equal "Hallo" <|
                    Translation.withDefault NL ZH missingTranslations
        , test "Returns an empty string" <|
            \_ ->
                Expect.equal "" <|
                    Translation.withDefault EN ZH missingTranslations
        , test "Returns the correct iso639 string" <|
            \_ ->
                Expect.equal [ "nl", "en", "zh" ] <|
                    List.map Translation.toIso639 [ NL, EN, ZH ]
        , test "Decodes translations" <|
            \_ ->
                Expect.equal (Ok translation) <|
                    Decode.decodeString Translation.fromJson json
        ]


translation : Translation
translation =
    Translation.fromList
        [ ( NL, "Hallo" )
        , ( EN, "Hello" )
        ]


missingTranslations : Translation
missingTranslations =
    Translation.fromList
        [ ( NL, "Hallo" ) ]


json : String
json =
    Encode.encode 0 <|
        Encode.object
            [ ( "nl", Encode.string "Hallo" )
            , ( "en", Encode.string "Hello" )
            ]
