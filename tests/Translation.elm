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
        [ test "Returns an empty string" <|
            \_ ->
                Expect.equal "" <|
                    Translation.toString EN Translation.empty
        , test "Returns a translated string" <|
            \_ ->
                Expect.equal "Hello" <|
                    Translation.toString EN translation
        , test "Returns a translated string and unescapes chars" <|
            \_ ->
                Expect.equal "\"Hello\"" <|
                    Translation.toString EN translationEscaped
        , test "Returns a translated string and removes html nodes" <|
            \_ ->
                Expect.equal "Hallo" <|
                    Translation.toString NL htmlTranslation
        , test "Returns the orginal translated string" <|
            \_ ->
                Expect.equal "<p>Hallo</p>" <|
                    Translation.toStringEscaped NL htmlTranslation
        , test "Returns an fallback string" <|
            \_ ->
                Expect.equal "Hallo" <|
                    Translation.withDefault NL ZH missingTranslations
        , test "Returns an unescaped fallback string" <|
            \_ ->
                Expect.equal "\"Hello\"" <|
                    Translation.withDefault EN ZH translationEscaped
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
                Html.article [] (Translation.html NL htmlTranslation)
                    |> Query.fromHtml
                    |> Query.find [ tag "p" ]
                    |> Query.has [ text "Hallo" ]
        , test "Is empty Translation" <|
            \_ ->
                Expect.true "Expected the String to be empty" <|
                    Translation.isEmpty NL (Translation.fromList [])
        , test "Is not empty Translation" <|
            \_ ->
                Expect.false "Expected the String to not be empty" <|
                    Translation.isEmpty NL translation
        ]


translation : Translation
translation =
    Translation.fromList
        [ ( NL, "Hallo" )
        , ( EN, "Hello" )
        ]


translationEscaped : Translation
translationEscaped =
    Translation.fromList
        [ ( EN, "&quot;Hello&quot;" )
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


json : String
json =
    Encode.encode 0 <|
        Encode.object
            [ ( "nl", Encode.string "Hallo" )
            , ( "en", Encode.string "Hello" )
            ]
