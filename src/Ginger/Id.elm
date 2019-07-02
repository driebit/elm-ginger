module Ginger.Id exposing
    ( ResourceId
    , toInt
    , toString
    , fromUrl
    , fromJson
    )

{-|


# Definition

@docs ResourceId


# Convert

@docs toInt
@docs toString


# Decode

@docs fromUrl
@docs fromJson

-}

import Json.Decode as Decode
import Tagged exposing (Tagged)
import Url.Parser as Url


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
fromUrl : Url.Parser (ResourceId -> a) a
fromUrl =
    Url.map Tagged.tag Url.int


{-| -}
fromJson : Decode.Decoder ResourceId
fromJson =
    Decode.map Tagged.tag Decode.int
