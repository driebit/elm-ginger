module Translation exposing (suite)

import Expect exposing (Expectation)
import Ginger.Translation as Translation exposing (Language(..), Translation)
import Html
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (tag, text)


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
        , test "Renders a translated text as html" <|
            \_ ->
                Html.article [] [ Translation.text NL translation ]
                    |> Query.fromHtml
                    |> Query.has [ text "Hallo" ]
        , test "Renders a translated html as html" <|
            \_ ->
                Html.article [] [ Translation.html NL htmlTranslation ]
                    |> Query.fromHtml
                    |> Query.find [ tag "p" ]
                    |> Query.has [ text "Hallo" ]
        , test "Renders error if translated html is invalid" <|
            \_ ->
                Html.article [] [ Translation.html NL invalidHtml ]
                    |> Query.fromHtml
                    |> Query.has [ text "Html could not be parsed" ]
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


htmlTranslation : Translation
htmlTranslation =
    Translation.fromList
        [ ( NL, "<p>Hallo</p>" )
        ]


invalidHtml : Translation
invalidHtml =
    Translation.fromList
        [ ( NL, "Hallo</p>" )
        ]


json : String
json =
    Encode.encode 0 <|
        Encode.object
            [ ( "nl", Encode.string "Hallo" )
            , ( "en", Encode.string "Hello" )
            ]
