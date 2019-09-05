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

import Html exposing (..)
import Html.Lazy as Lazy
import Html.Parser
import Html.Parser.Util
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
            \l t -> { t | en = l }

        NL ->
            \l t -> { t | nl = l }

        ZH ->
            \l t -> { t | zh = l }



-- CONVERSIONS


{-| Get the translated String value.

_Defaults to an empty String._

-}
toString : Language -> Translation -> String
toString language (Translation translation) =
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


{-| Construct a Translation from a list of Language and String value pairs
-}
fromList : List ( Language, String ) -> Translation
fromList =
    List.foldl (\( language, s ) acc -> languageModifier language s acc)
        { en = "", nl = "", zh = "" }
        >> Translation


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
html : Language -> Translation -> List (Html msg)
html language translation =
    html_ (toString language translation)


html_ : String -> List (Html msg)
html_ s =
    let
        parsedString =
            Result.map Html.Parser.Util.toVirtualDom <|
                Html.Parser.run s
    in
    case parsedString of
        Err _ ->
            [ Html.text "Html could not be parsed" ]

        Ok ok ->
            ok



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
