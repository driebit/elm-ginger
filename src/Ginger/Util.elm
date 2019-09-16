module Ginger.Util exposing
    ( stripHtml
    , toHtml
    )

{-|


# Html

@docs stripHtml
@docs toHtml

-}

import Html exposing (..)
import Html.Parser
import Html.Parser.Util
import Internal.Html


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


    >>> "Hola!"

_This unescapes html unicode characters as well.
If parsing fails the original String is returned_

-}
stripHtml : String -> String
stripHtml =
    Internal.Html.stripHtml
