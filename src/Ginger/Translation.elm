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
import Html exposing (Html)
import Html.Parser
import Html.Parser.Util
import Internal.Html
import Json.Decode as Decode
import Parser



-- DEFINITIONS


{-| -}
type Translation
    = Translation (Dict String ( OriginalString, Result (List Parser.DeadEnd) (List Html.Parser.Node) ))


type alias OriginalString =
    String


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
    Translation << Dict.fromList << List.filterMap (fromPair << Tuple.mapFirst toIso639)



-- CONVERSIONS


{-| Get the translated `String` value.

_Unescapes character entity references, strips Html nodes and defaults to an empty String._

-}
toString : Language -> Translation -> String
toString language (Translation translation) =
    case Dict.get (toIso639 language) translation of
        Nothing ->
            ""

        Just ( s, Err _ ) ->
            s

        Just ( _, Ok nodes ) ->
            Internal.Html.textNodes nodes


{-| Get the _original_ translated `String` value as returned by the REST api.
_Defaults to an empty String._
-}
toStringEscaped : Language -> Translation -> String
toStringEscaped language (Translation translation) =
    Dict.get (toIso639 language) translation
        |> Maybe.map Tuple.first
        |> Maybe.withDefault ""


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
    Dict.get (toIso639 language) translation == Nothing



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

        Just ( s, Err _ ) ->
            []

        Just ( _, Ok nodes ) ->
            Html.Parser.Util.toVirtualDom nodes


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
        decode pair acc =
            case fromPair pair of
                Nothing ->
                    acc

                Just ( k, v ) ->
                    Dict.insert k v acc
    in
    Decode.map (Translation << List.foldl decode Dict.empty) <|
        Decode.keyValuePairs Decode.string


fromPair : ( String, String ) -> Maybe ( String, ( OriginalString, Result (List Parser.DeadEnd) (List Html.Parser.Node) ) )
fromPair ( k, v ) =
    if String.isEmpty v then
        Nothing

    else
        case Html.Parser.run v of
            Ok [] ->
                Nothing

            Ok nodes ->
                Just ( k, ( v, Ok nodes ) )

            Err err ->
                Just ( k, ( v, Err err ) )
