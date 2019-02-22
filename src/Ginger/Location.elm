module Ginger.Location exposing (Location, fromJson)

import Ginger.Id exposing (Id)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline



-- DEFINITION


type alias Location =
    { id : Id
    , lat : Float
    , lng : Float
    }



-- DECODE


fromJson : Decode.Decoder Location
fromJson =
    Decode.succeed Location
        |> Pipeline.required "id" Ginger.Id.fromJson
        |> Pipeline.required "lat" Decode.float
        |> Pipeline.required "lng" Decode.float
