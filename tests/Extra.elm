module Extra exposing (suite)

import Expect exposing (Expectation)
import Ginger.Translation as Translation exposing (Language(..), Translation)
import Html
import Internal.Html
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (tag, text)


suite : Test
suite =
    describe "The Internal Html module"
        [ test "Renders a text as html" <|
            \_ ->
                Html.article [] (Internal.Html.toHtml "Hallo")
                    |> Query.fromHtml
                    |> Query.has [ text "Hallo" ]
        , test "Renders a html as html" <|
            \_ ->
                Html.article [] (Internal.Html.toHtml "<p>Hallo</p>")
                    |> Query.fromHtml
                    |> Query.find [ tag "p" ]
                    |> Query.has [ text "Hallo" ]
        , test "Renders a text as html and unescapes chars" <|
            \_ ->
                Html.article [] (Internal.Html.toHtml "&quot;Hallo&quot; &quot;wereld&quot;")
                    |> Query.fromHtml
                    |> Query.has [ text "\"Hallo\" \"wereld\"" ]
        , test "Renders error if translated html is invalid" <|
            \_ ->
                Html.article [] (Internal.Html.toHtml "Hallo</p>")
                    |> Query.fromHtml
                    |> Query.has [ text "Html could not be parsed" ]
        , test "Renders a text as html, unescapes chars and removes nodes" <|
            \_ ->
                Html.article [] [ Html.text (Internal.Html.stripHtml "<i>&quot;Hallo&quot;</i><b>&quot;wereld&quot;</b>") ]
                    |> Query.fromHtml
                    |> Query.has [ text "\"Hallo\"\"wereld\"" ]
        , test "Renders a text as html, unescapes chars, remove nodes and preserves spaces" <|
            \_ ->
                Html.article [] [ Html.text (Internal.Html.stripHtml "<i>&quot;Hallo&quot;</i> <b>&quot;wereld&quot;</b>") ]
                    |> Query.fromHtml
                    |> Query.has [ text "\"Hallo\" \"wereld\"" ]
        , test "Renders a text as html, preserves unescaped chars" <|
            \_ ->
                Html.article [] [ Html.text (Internal.Html.stripHtml "10 < 100 && 100 < 1000") ]
                    |> Query.fromHtml
                    |> Query.has [ text "10 < 100 && 100 < 1000" ]
        ]
