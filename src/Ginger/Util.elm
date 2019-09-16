module Ginger.Util exposing
    ( viewIf
    , viewIfNot
    , viewEither
    , viewMaybe
    , viewMaybeWithDefault
    , stripHtml
    , toHtml
    , truncate
    )

{-| This module contains some useful functions for parsing and rendering `Html`.


# Conditional views

@docs viewIf
@docs viewIfNot
@docs viewEither


# Optional views

@docs viewMaybe
@docs viewMaybeWithDefault


# Parse Html

@docs stripHtml
@docs toHtml


# String manipulation

@docs truncate

-}

import Html exposing (..)
import Html.Parser
import Html.Parser.Util
import Internal.Html


{-| Render some html if a boolean expression evaluates to `True`.

    view : Model -> Html msg
    view model =
        article []
            [ h1 [] [ text model.title ]
            , viewIf
                (model.category == Category.Article)
                (\_ -> p [] [ text "article" ])
            ]

-}
viewIf : Bool -> (() -> Html msg) -> Html msg
viewIf bool html1 =
    if bool then
        html1 ()

    else
        text ""


{-| Render some html if a boolean expression evaluates to `False`.
-}
viewIfNot : Bool -> (() -> Html msg) -> Html msg
viewIfNot bool html1 =
    viewIf (not bool) html1


{-| If the boolean expression evaluates to `True`, render some html, otherwise,
render some other html.

    view : Model -> Html msg
    view model =
        , article []
            [ h1 [] [ text model.title ]
            , p []
                [ viewEither (model.category == Category.Article)
                    (\_ -> text "article")
                    (\_ -> text "something else")
                ]
            ]

-}
viewEither : Bool -> (() -> Html msg) -> (() -> Html msg) -> Html msg
viewEither bool html1 html2 =
    if bool then
        html1 ()

    else
        html2 ()


{-| Maybe, the resource has an author. Render what's in the `maybe`, or nothing.

    view : Model -> Html msg
    view model =
        article []
            [ h1 [] [ text "Article" ]
            , viewMaybe model.author
                (\authorName -> p [] [ text authorName ])
            ]

-}
viewMaybe : Maybe a -> (a -> Html msg) -> Html msg
viewMaybe maybeA html1 =
    case maybeA of
        Just a ->
            html1 a

        Nothing ->
            text ""


{-| Render something else if there's nothing in the `maybe`.

    view : Model -> Html msg
    view model =
        article []
            [ h1 [] [ text "Article" ]
            , p []
                [ viewMaybeWithDefault model.author
                    (\_ -> text "Anonymous")
                    (\authorName -> text authorName)
                ]
            ]

-}
viewMaybeWithDefault : Maybe a -> (() -> Html msg) -> (a -> Html msg) -> Html msg
viewMaybeWithDefault maybeA default html1 =
    case maybeA of
        Just a ->
            html1 a

        Nothing ->
            default ()


{-| Convert a String to Html

_This unescapes html unicode characters as well_

-}
toHtml : String -> List (Html msg)
toHtml =
    Internal.Html.toHtml


{-| Remove all Html nodes from a String

    example :: String
    example =
        stripHtml "<p>Hola!</p>"

    --> "Hola!"

_This unescapes html unicode characters as well.
If parsing fails the original String is returned_

-}
stripHtml : String -> String
stripHtml =
    Internal.Html.stripHtml


{-| Truncate a String and append `...` if the String is longer than provided length


    example : String
    example =
        truncate 10 "Truncate a String and append `...` if the String is longer than provided length"

    --> "Truncate a..."

-}
truncate : Int -> String -> String
truncate length s =
    let
        letters =
            String.split ""
    in
    if String.length s > length then
        String.left length s ++ "..."

    else
        s
