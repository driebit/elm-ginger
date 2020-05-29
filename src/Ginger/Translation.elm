module Ginger.Translation exposing
    ( Translation
    , Language(..)
    , empty
    , fromList
    , toString
    , toStringEscaped
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
    Dict String String


type Text
    = Plain
    | Markup


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


{-| An empty 'Translation'
-}
empty : Translation
empty =
    Translation Dict.empty


{-| Construct a Translation from a list of Language and String value pairs
-}
fromList : List ( Language, String ) -> Translation
fromList languageValuePairs =
    Translation <|
        Dict.fromList <|
            List.map (\( language, value ) -> ( toIso639 language, value )) languageValuePairs



-- CONVERSIONS


{-| Get the translated String value.

_Unescapes character entity references, strips Html nodes and defaults to an empty String._

-}
toString : Language -> Translation -> String
toString language translation =
    Internal.Html.stripHtml (get language translation)


{-| Get the _original_ translated String value as returned by the REST api.

_Defaults to an empty String._

-}
toStringEscaped : Language -> Translation -> String
toStringEscaped language translation =
    get language translation


{-| Get the translated String value.

The first argument is the fallback Language.

_Attempt fallback if translated value is missing, defaults to an empty String._

-}
withDefault : Language -> Language -> Translation -> String
withDefault def language translation =
    case toString language translation of
        "" ->
            toString def translation

        lang ->
            lang


{-| Checks if translated String is empty.
-}
isEmpty : Language -> Translation -> Bool
isEmpty language translation =
    String.isEmpty (get language translation)


{-| Convert a Language to an [Iso639](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) String
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
    let
        filter k v =
            String.length k == 2 && not (String.isEmpty v)
    in
    Decode.map Translation <|
        Decode.map (Dict.filter filter) <|
            Decode.dict Decode.string



-- HELPERS


get : Language -> Translation -> String
get language (Translation translation) =
    Maybe.withDefault "" <|
        Dict.get (toIso639 language) translation
