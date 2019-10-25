module Ginger.Menu exposing
    ( Menu
    , Item
    , Footer
    , empty
    , fromValue
    , fromJson
    )

{-|


# Definitions

@docs Menu
@docs Item
@docs Footer


# Construct

@docs empty


# Decode

@docs fromValue
@docs fromJson

-}

import Ginger.Id as Id exposing (ResourceId)
import Ginger.Translation as Translation exposing (Translation)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline



-- DEFINITIONS


{-| -}
type alias Menu =
    { main : List Item
    , footer : Footer
    }


{-| -}
type alias Footer =
    { title : Translation
    , summary : Translation
    , items : List Item
    }


{-| -}
type alias Item =
    { id : ResourceId
    , title : Translation
    , path : String
    }



-- CONSTRUCTION


{-| A `Menu` containing no values
-}
empty : Menu
empty =
    { main = []
    , footer = Footer Translation.empty Translation.empty []
    }


{-| Decode a `Menu` from a `Decode.Value`, defaults to an empty `Menu`

You can for example pass the menu as a flag and initialize you app like:

    main : Program Decode.Value Model Msg
    main =
        Browser.application
            { init = init << Ginger.Menu.fromValue
            , view = view
            , update = update
            , subscriptions = subscriptions
            , onUrlChange = OnUrlChange
            , onUrlRequest = OnUrlRequest
            }

-}
fromValue : Decode.Value -> Menu
fromValue =
    Decode.decodeValue fromJson
        >> Result.withDefault empty



-- DECODE


{-| -}
fromJson : Decoder Menu
fromJson =
    Decode.succeed Menu
        |> Pipeline.required "main_menu" (Decode.list decodeMenuItem)
        |> Pipeline.required "footer_menu" decodeFooter


decodeFooter : Decoder Footer
decodeFooter =
    Decode.succeed Footer
        |> Pipeline.optional "subtitle" Translation.fromJson Translation.empty
        |> Pipeline.optional "summary" Translation.fromJson Translation.empty
        |> Pipeline.required "items" (Decode.list decodeMenuItem)


decodeMenuItem : Decoder Item
decodeMenuItem =
    Decode.succeed Item
        |> Pipeline.required "id" Id.fromJson
        |> Pipeline.required "title" Translation.fromJson
        |> Pipeline.optional "page_url" Decode.string ""
