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


{-| Get the translated String value.

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
-}
text : Language -> Translation -> Html msg
text language translation =
    Html.text (toString language translation)


{-| Translate and render as Html markup
-}
html : Language -> Translation -> Html msg
html language translation =
    Lazy.lazy html_ (toString language translation)


{-| Prevent re-render on calling elm-update
<https://github.com/elm-explorations/markdown/issues/3>
-}
html_ : String -> Html msg
html_ =
    Markdown.toHtmlWith { defaultOptions | sanitize = False } []



-- DECODE


{-| -}
fromJson : Decode.Decoder Translation
fromJson =
    Decode.map Translation <|
        Decode.dict Decode.string
