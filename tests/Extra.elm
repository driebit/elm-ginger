module Extra exposing (suite)

import Expect exposing (Expectation)
import Ginger.Translation as Translation exposing (Language(..), Translation)
import Ginger.Util
import Html
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (tag, text)


suite : Test
suite =
    describe "The Ginger.Extra module"
        [ test "Renders a text as html" <|
            \_ ->
                Html.article [] (Ginger.Util.toHtml "Hallo")
                    |> Query.fromHtml
                    |> Query.has [ text "Hallo" ]
        , test "Renders a html as html" <|
            \_ ->
                Html.article [] (Ginger.Util.toHtml "<p>Hallo</p>")
                    |> Query.fromHtml
                    |> Query.find [ tag "p" ]
                    |> Query.has [ text "Hallo" ]
        , test "Renders a text as html and unescapes chars" <|
            \_ ->
                Html.article [] (Ginger.Util.toHtml "&quot;Hallo&quot; &quot;wereld&quot;")
                    |> Query.fromHtml
                    |> Query.has [ text "\"Hallo\" \"wereld\"" ]
        , test "Renders error if translated html is invalid" <|
            \_ ->
                Html.article [] (Ginger.Util.toHtml "Hallo</p>")
                    |> Query.fromHtml
                    |> Query.has [ text "Html could not be parsed" ]
        , test "Renders a text as html, unescapes chars and removes nodes" <|
            \_ ->
                Html.article [] [ Html.text (Ginger.Util.stripHtml "<i>&quot;Hallo&quot;</i><b>&quot;wereld&quot;</b>") ]
                    |> Query.fromHtml
                    |> Query.has [ text "\"Hallo\"\"wereld\"" ]
        , test "Renders a text as html, unescapes chars, remove nodes and preserves spaces" <|
            \_ ->
                Html.article [] [ Html.text (Ginger.Util.stripHtml "<i>&quot;Hallo&quot;</i> <b>&quot;wereld&quot;</b>") ]
                    |> Query.fromHtml
                    |> Query.has [ text "\"Hallo\" \"wereld\"" ]
        , test "Renders a text as html, preserves unescaped chars" <|
            \_ ->
                Html.article [] [ Html.text (Ginger.Util.stripHtml "10 < 100 && 100 < 1000") ]
                    |> Query.fromHtml
                    |> Query.has [ text "10 < 100 && 100 < 1000" ]
        , describe "Conditional views"
            [ test "viewIf renders html if boolean is True" <|
                \() ->
                    Ginger.Util.viewIf True
                        (\_ -> Html.text "I should be rendered!")
                        |> Query.fromHtml
                        |> Query.has [ text "I should be rendered!" ]
            , test "viewIf renders no html if boolean is False" <|
                \() ->
                    Ginger.Util.viewIf False
                        (\_ -> Html.text "I should not be rendered!")
                        |> Query.fromHtml
                        |> Query.hasNot [ text "I should not be rendered!" ]
            , test "viewIfNot renders html if boolean is False" <|
                \() ->
                    Ginger.Util.viewIfNot False
                        (\_ -> Html.text "I should be rendered!")
                        |> Query.fromHtml
                        |> Query.has [ text "I should be rendered!" ]
            , test "viewIfNot renders no html if boolean is True" <|
                \() ->
                    Ginger.Util.viewIfNot True
                        (\_ -> Html.text "I should not be rendered!")
                        |> Query.fromHtml
                        |> Query.hasNot [ text "I should not be rendered!" ]
            ]
        , describe "Optional views"
            [ test "viewMaybe renders nothing if there's nothing in the Maybe" <|
                \() ->
                    Ginger.Util.viewMaybe Nothing
                        (\_ -> Html.text "Nothing should be rendered!")
                        |> Query.fromHtml
                        |> Query.hasNot [ text "Nothing should be rendered!" ]
            , test "viewMaybe renders something if there's something in the Maybe" <|
                \() ->
                    Ginger.Util.viewMaybe (Just "Something")
                        (\x -> Html.text (x ++ " should be rendered!"))
                        |> Query.fromHtml
                        |> Query.has [ text "Something should be rendered!" ]
            ]
        , describe "String manipulation"
            [ test "truncates the string to provided length" <|
                \() ->
                    Ginger.Util.truncate 3 "123456789"
                        |> Expect.equal "123..."
            , test "doesn't truncate string if shorter than provided length" <|
                \() ->
                    Ginger.Util.truncate 10 "123456789"
                        |> Expect.equal "123456789"
            ]
        ]
