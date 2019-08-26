module Ginger.Translation exposing
    ( Translation
    , Language(..)
    , toString
    , withDefault
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
@docs withDefault
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
import Html.Lazy as Lazy
import Html.Parser
import Html.Parser.Util
import Json.Decode as Decode



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


{-| Get the translated String value.

The first argument is the fallback Language.

_Attempt fallback if translated value is missing, defaults to an empty String._

-}
withDefault : Language -> Language -> Translation -> String
withDefault def language (Translation translation) =
    Dict.get (toIso639 language) translation
        |> Maybe.withDefault
            (Maybe.withDefault "" (Dict.get (toIso639 def) translation))


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

We try to unescape the escaped characters but if that fails we'll render the `Translation` as is.

Html elements will be filtered out and the text will be joined.

-}
text : Language -> Translation -> Html msg
text language translation =
    text_ (toString language translation)


text_ : String -> Html msg
text_ s =
    let
        textNodes n acc =
            case n of
                Html.Parser.Text t ->
                    t ++ acc

                Html.Parser.Element _ _ n_ ->
                    List.foldr textNodes acc n_

                _ ->
                    acc

        parsedString =
            Result.map (List.foldr textNodes "") <|
                Html.Parser.run s
    in
    case parsedString of
        Err _ ->
            Html.text s

        Ok t ->
            Html.text t


{-| Translate and render as Html markup
-}
html : Language -> Translation -> Html msg
html language translation =
    Lazy.lazy html_ (toString language translation)


html_ : String -> Html msg
html_ s =
    let
        parsedString =
            Result.map Html.Parser.Util.toVirtualDom <|
                Html.Parser.run s
    in
    case parsedString of
        Err _ ->
            -- TODO: Remove wrapping div in the next major release
            div [] [ Html.text "Html could not be parsed" ]

        Ok ok ->
            -- TODO: Remove wrapping div in the next major release
            div [] ok



-- DECODE


{-| -}
fromJson : Decode.Decoder Translation
fromJson =
    Decode.map Translation <|
        Decode.dict Decode.string
