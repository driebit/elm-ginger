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
                Translation.isEmpty NL (Translation.fromList [])
                    |> Expect.equal True
                    |> Expect.onFail "Expected the String to be empty"
        , test "Is empty Translation with empty string" <|
            \_ ->
                Translation.isEmpty NL (Translation.fromList [ ( NL, "" ) ])
                    |> Expect.equal True
                    |> Expect.onFail "Expected the String to be empty"
        , test "Is non empty Translation" <|
            \_ ->
                Translation.isEmpty NL (Translation.fromList [ ( NL, "fire" ) ])
                    |> Expect.equal False
                    |> Expect.onFail "Expected the String to be non empty"
        , test "Is not empty Translation" <|
            \_ ->
                Translation.isEmpty NL translation
                    |> Expect.equal False
                    |> Expect.onFail "Expected the String to be non empty"
        , test "Renders a Dutch text as html" <|
            \_ ->
                Html.article [] [ Translation.textNL translation ]
                    |> Query.fromHtml
                    |> Query.has [ text "Hallo" ]
        , test "Renders a English text as html" <|
            \_ ->
                Html.article [] [ Translation.textEN translation ]
                    |> Query.fromHtml
                    |> Query.has [ text "Hello" ]
        , test "Renders a Dutch markup as html" <|
            \_ ->
                Html.article [] (Translation.htmlNL htmlTranslation)
                    |> Query.fromHtml
                    |> Query.has [ text "Hallo" ]
        , test "Renders a English markup as html" <|
            \_ ->
                Html.article [] (Translation.htmlEN htmlTranslation)
                    |> Query.fromHtml
                    |> Query.has [ text "Hello" ]
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
        , ( EN, "<p>Hello</p>" )
        ]


json : String
json =
    Encode.encode 0 <|
        Encode.object
            [ ( "nl", Encode.string "Hallo" )
            , ( "en", Encode.string "Hello" )
            ]
