module Internal.Html exposing (stripHtml, toHtml)

import Html exposing (..)
import Html.Parser
import Html.Parser.Util


{-| Convert a String to elm html

This unescapes html unicode characters as well

-}
toHtml : String -> List (Html msg)
toHtml s =
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


{-| A remove all html nodes from a String

    example :: String
    example =
        stripHtml "<p>Hola!</p>"


    --> "Hola!"

This unescapes html unicode characters as well

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
