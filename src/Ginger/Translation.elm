module Ginger.Translation exposing
    ( Translation
    , Language(..)
    , empty
    , fromList
    , toString
    , toStringEscaped
    , toNodes
    , withDefault
    , toIso639
    , isEmpty
    , text
    , html
    , textNL
    , htmlNL
    , textEN
    , htmlEN
    , fromJson
    )

{-|


# Definitions

@docs Translation
@docs Language


# Construct

@docs empty
@docs fromList


# Convert

@docs toString
@docs toStringEscaped
@docs toNodes
@docs withDefault
@docs toIso639
@docs isEmpty


# Render as Html

@docs text
@docs html


# Render in language

@docs textNL
@docs htmlNL
@docs textEN
@docs htmlEN


# Decode

@docs fromJson

-}

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Parser
import Html.Parser.Util
import Internal.Html
import Json.Decode as Decode
import Parser



-- DEFINITIONS


{-| -}
type Translation
    = Translation (Dict String String)


{-| -}
type Language
    = AR
    | DE
    | EN
    | ES
    | ET
    | FR
    | ID
    | NL
    | PL
    | RU
    | SR
    | TR
    | ZH
    | Custom String


{-| Convert a `Language` to an [Iso639](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) `String`
-}
toIso639 : Language -> String
toIso639 language =
    case language of
        AR ->
            "ar"

        DE ->
            "de"

        EN ->
            "en"

        ES ->
            "es"

        ET ->
            "et"

        FR ->
            "fr"

        ID ->
            "id"

        NL ->
            "nl"

        PL ->
            "pl"

        RU ->
            "ru"

        SR ->
            "sr"

        TR ->
            "tr"

        ZH ->
            "zh"

        Custom s ->
            s


{-| An empty 'Translation'
-}
empty : Translation
empty =
    Translation Dict.empty


{-| Construct a `Translation` from a list of `Language` and `String` value pairs

_Empty Strings will be ignored_

-}
fromList : List ( Language, String ) -> Translation
fromList =
    Translation << Dict.fromList << List.map (Tuple.mapFirst toIso639)



-- CONVERSIONS


{-| Get the translated `String` value.

_Unescapes character entity references, strips Html nodes and defaults to an empty String._

-}
toString : Language -> Translation -> String
toString language (Translation translation) =
    case Dict.get (toIso639 language) translation of
        Nothing ->
            ""

        Just s ->
            Internal.Html.stripHtml s


{-| Get the _original_ translated `String` value as returned by the REST api.

_Defaults to an empty String._

-}
toStringEscaped : Language -> Translation -> String
toStringEscaped language (Translation translation) =
    case Dict.get (toIso639 language) translation of
        Nothing ->
            ""

        Just s ->
            s


{-| Get the translated `String` value.

The first argument is the fallback `Language`.

_Attempt fallback if translated value is missing, defaults to an empty String._

-}
withDefault : Language -> Language -> Translation -> String
withDefault def language translation =
    case toString language translation of
        "" ->
            toString def translation

        lang ->
            lang


{-| Checks if translated `String` is empty.
-}
isEmpty : Language -> Translation -> Bool
isEmpty language (Translation translation) =
    let
        val =
            Dict.get (toIso639 language) translation
    in
    val == Nothing || val == Just ""



-- NODES


{-| Get translated `String` as `hecrj/html-parser` `Node`s

_Defaults to an empty `List` if parsing fails._

-}
toNodes : Language -> Translation -> List Html.Parser.Node
toNodes language (Translation translation) =
    Maybe.withDefault [] <|
        Maybe.andThen (Result.toMaybe << Html.Parser.run) <|
            Dict.get (toIso639 language) translation



-- HTML


{-| Translate and render as Html text

We try to unescape the escaped characters but if that fails we'll render the `Translation` as is.

Html elements will be filtered out and the text will be concatenated.

-}
text : Language -> Translation -> Html msg
text language translation =
    Html.text (toString language translation)


{-| Translate and render as Html markup
-}
html : Language -> Translation -> List (Html msg)
html language (Translation translation) =
    case Dict.get (toIso639 language) translation of
        Nothing ->
            []

        Just s ->
            Internal.Html.toHtml s


{-| Translate to Dutch and render as Html text
-}
textNL : Translation -> Html msg
textNL =
    text NL


{-| Translate to Dutch and render as Html markup
-}
htmlNL : Translation -> List (Html msg)
htmlNL =
    html NL


{-| Translate to English and render as Html text
-}
textEN : Translation -> Html msg
textEN =
    text EN


{-| Translate to English and render as Html markup
-}
htmlEN : Translation -> List (Html msg)
htmlEN =
    html EN



-- DECODE


{-| -}
fromJson : Decode.Decoder Translation
fromJson =
    Decode.map Translation <|
        Decode.dict Decode.string
