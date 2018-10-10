module Ginger.Translation exposing
    ( Language(..)
    , Translation
    , fromJson
    , fromList
    , html
    , map
    , text
    , toString
    )

import Dict exposing (Dict)
import Html exposing (..)
import Json.Decode as Decode
import Markdown exposing (defaultOptions)



-- DEFINITIONS


type Translation
    = Translation (Dict String String)


type Language
    = NL
    | EN



-- DECODE


fromJson : Decode.Decoder Translation
fromJson =
    Decode.map Translation <|
        Decode.dict Decode.string



-- CONVERSIONS


toString : Language -> Translation -> String
toString language (Translation translation) =
    Maybe.withDefault "" <|
        Dict.get (toIso639 language) translation


map : (String -> String) -> Translation -> Translation
map fn (Translation translation) =
    Translation <|
        Dict.map (\_ value -> fn value) translation


fromList : List ( Language, String ) -> Translation
fromList =
    Translation << Dict.fromList << List.map (Tuple.mapFirst toIso639)



-- HTML


text : Language -> Translation -> Html msg
text language translation =
    Html.text (toString language translation)


html : Language -> Translation -> Html msg
html language translation =
    Markdown.toHtmlWith { defaultOptions | sanitize = False } [] <|
        toString language translation



-- LANGUAGE


toIso639 : Language -> String
toIso639 language =
    case language of
        EN ->
            "en"

        NL ->
            "nl"
