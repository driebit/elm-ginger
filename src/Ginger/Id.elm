module Ginger.Id exposing
    ( ResourceId
    , toInt
    , toString
    , fromJson
    )

{-|


# Definition

@docs ResourceId


# Convert

@docs toInt
@docs toString


# Decode

@docs fromJson

-}

import Json.Decode as Decode
import Tagged exposing (Tagged)


{-| -}
type alias ResourceId =
    Tagged Resource Int


type Resource
    = Resource


{-| -}
toInt : ResourceId -> Int
toInt =
    Tagged.untag


{-| -}
toString : ResourceId -> String
toString =
    String.fromInt << Tagged.untag


{-| -}
fromJson : Decode.Decoder ResourceId
fromJson =
    Decode.map Tagged.tag Decode.int
