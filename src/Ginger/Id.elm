module Ginger.Id exposing
    ( Id(..)
    , toString
    , fromJson
    )

{-|


# Definitions

@docs Id


# Convert

@docs toString


# Decode

@docs fromJson

-}

import Json.Decode as Decode


{-| -}
type Id
    = Id Int


{-| -}
toString : Id -> String
toString (Id id) =
    String.fromInt id


{-| -}
fromJson : Decode.Decoder Id
fromJson =
    Decode.map Id Decode.int
