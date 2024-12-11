module Json.Decode.Extra exposing (..)

import Json.Decode as Decode exposing (Decoder)


constant : a -> String -> Decoder a
constant value expectedString =
    bind Decode.string <|
        \encounteredString ->
            if expectedString == encounteredString then
                Decode.succeed value

            else
                Decode.fail <|
                    "expected '"
                        ++ expectedString
                        ++ "' but got '"
                        ++ encounteredString
                        ++ "`"


bind : Decoder a -> (a -> Decoder b) -> Decoder b
bind d f =
    Decode.andThen f d
