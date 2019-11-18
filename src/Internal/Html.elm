module Internal.Html exposing
    ( stripHtml
    , toHtml
    , unescape
    )

import Html exposing (..)
import Html.Parser
import Html.Parser.Util


{-| Convert a String to elm html

This unescapes character entity references as well

_Will show an error if parsing fails_

-}
toHtml : String -> List (Html msg)
toHtml s =
    Result.withDefault [ text "Html could not be parsed" ] <|
        Result.map Html.Parser.Util.toVirtualDom <|
            Html.Parser.run s


{-| A remove all html nodes from a String

    example :: String
    example =
        stripHtml "<p>Hola!</p>"


    --> "Hola!"

This unescapes character entity references as well

-}
stripHtml : String -> String
stripHtml s =
    let
        textNodes n acc =
            case n of
                Html.Parser.Text t ->
                    t ++ acc

                Html.Parser.Element _ _ n_ ->
                    List.foldr textNodes acc n_

                _ ->
                    acc
    in
    Result.withDefault s <|
        Result.map (List.foldr textNodes "") <|
            Html.Parser.run s


{-| Unescape character entity references

_Defaults to original String if parsing fails_

-}
unescape : String -> String
unescape s =
    Result.withDefault s <|
        Result.map (String.concat << List.map Html.Parser.nodeToString) <|
            Html.Parser.run s
