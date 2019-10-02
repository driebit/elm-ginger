module Ginger.Translation exposing
    ( Translation
    , Language(..)
    , toString
    , toStringEscaped
    , withDefault
    , isEmpty
    , fromList
    , toIso639
    , text
    , html
    , fromJson
    )

{-|


# Definitions

@docs Translation
@docs Language


# Conversion

@docs toString
@docs toStringEscaped
@docs withDefault
@docs isEmpty
@docs fromList
@docs toIso639


# Html

@docs text
@docs html


# Decode

@docs fromJson

-}

import Html exposing (..)
import Html.Lazy as Lazy
import Html.Parser
import Html.Parser.Util
import Internal.Html
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline



-- DEFINITIONS


{-| -}
type Translation
    = Translation Translations


type alias Translations =
    { en : String
    , nl : String
    , zh : String
    }


{-| -}
type Language
    = EN
    | NL
    | ZH


languageAccessor : Language -> (Translations -> String)
languageAccessor language =
    case language of
        EN ->
            .en

        NL ->
            .nl

        ZH ->
            .zh


languageModifier : Language -> (String -> Translations -> Translations)
languageModifier language =
    case language of
        EN ->
            \value translations -> { translations | en = value }

        NL ->
            \value translations -> { translations | nl = value }

        ZH ->
            \value translations -> { translations | zh = value }



-- CONVERSIONS


{-| Get the translated String value.

_Unescapes character entity references, strips Html nodes and defaults to an empty String._

-}
toString : Language -> Translation -> String
toString language (Translation translation) =
    Internal.Html.stripHtml (languageAccessor language translation)


{-| Get the _original_ translated String value as returned by the REST api.

_Defaults to an empty String._

-}
toStringEscaped : Language -> Translation -> String
toStringEscaped language (Translation translation) =
    languageAccessor language translation


{-| Get the translated String value.

The first argument is the fallback Language.

_Attempt fallback if translated value is missing, defaults to an empty String._

-}
withDefault : Language -> Language -> Translation -> String
withDefault def language (Translation translation) =
    case languageAccessor language translation of
        "" ->
            languageAccessor def translation

        lang ->
            lang


{-| Checks if translated String is empty.
-}
isEmpty : Language -> Translation -> Bool
isEmpty language (Translation translation) =
    String.isEmpty (languageAccessor language translation)


{-| Construct a Translation from a list of Language and String value pairs
-}
fromList : List ( Language, String ) -> Translation
fromList languageValuePairs =
    Translation <|
        List.foldl (\( language, value ) acc -> languageModifier language value acc)
            { en = "", nl = "", zh = "" }
            languageValuePairs


{-| Convert a Language to an [Iso639](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) String
-}
toIso639 : Language -> String
toIso639 language =
    case language of
        EN ->
            "en"

        NL ->
            "nl"

        ZH ->
            "zh"



-- HTML


{-| Translate and render as Html text

We try to unescape the escaped characters but if that fails we'll render the `Translation` as is.

Html elements will be filtered out and the text will be joined.

-}
text : Language -> Translation -> Html msg
text language translation =
    Html.text (toString language translation)


{-| Translate and render as Html markup
-}
html : Language -> Translation -> List (Html msg)
html language translation =
    Internal.Html.toHtml (toStringEscaped language translation)



-- DECODE


{-| -}
fromJson : Decode.Decoder Translation
fromJson =
    Decode.map Translation <|
        (Decode.succeed Translations
            |> Pipeline.optional "en" Decode.string ""
            |> Pipeline.optional "nl" Decode.string ""
            |> Pipeline.optional "zh" Decode.string ""
        )
