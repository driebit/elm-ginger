module Ginger.Id exposing
    ( ResourceId
    , toInt
    , toString
    , fromUrl
    , fromJson
    )

{-| The Ginger resource id. We 'tag' the resource id with type `Int`
using [elm-tagged](https://package.elm-lang.org/packages/joneshf/elm-tagged/2.1.1/).
This helps us to not mix up some other `Int` with a resource id by accident.

_The only way to construct a `ResourceId` is by decoding one from some json or
parsing it out of an url path. This is rather strict and there might be some times
you just need to create a random `ResourceId` for whatever reason, this hasn't
come up so far, but file an issue if it does._


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
