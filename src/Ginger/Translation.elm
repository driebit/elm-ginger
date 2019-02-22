module Ginger.Translation exposing
    ( Translation
    , Language(..)
    , toString
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
@docs fromList
@docs toIso639


# Html

@docs text
@docs html


# Decode

@docs fromJson

-}

import Dict exposing (Dict)
import Html exposing (..)
import Json.Decode as Decode
import Markdown exposing (defaultOptions)



-- DEFINITIONS


{-| -}
type Translation
    = Translation (Dict String String)


{-| -}
type Language
    = NL
    | EN
    | ZH



-- CONVERSIONS


{-| Get the translated String value.

_Defaults to an empty String._

-}
toString : Language -> Translation -> String
toString language (Translation translation) =
    Maybe.withDefault "" <|
        Dict.get (toIso639 language) translation


{-| Construct a Translation from a list of Language and String value pairs
-}
fromList : List ( Language, String ) -> Translation
fromList =
    Translation << Dict.fromList << List.map (Tuple.mapFirst toIso639)


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
-}
text : Language -> Translation -> Html msg
text language translation =
    Html.text (toString language translation)


{-| Translate and render as Html markup
-}
html : Language -> Translation -> Html msg
html language translation =
    Markdown.toHtmlWith { defaultOptions | sanitize = False } [] <|
        toString language translation



-- DECODE


{-| -}
fromJson : Decode.Decoder Translation
fromJson =
    Decode.map Translation <|
        Decode.dict Decode.string
