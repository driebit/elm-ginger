module Ginger.Menu exposing
    ( Menu
    , Item
    , Footer
    , empty
    , fromValue
    , fromJson
    , decodeMenuItems
    , decodeMenuItem
    , decodeFooter
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
@docs decodeMenuItems
@docs decodeMenuItem
@docs decodeFooter

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


{-| Build a custom menu `Decoder` re-using the decoders used in this module

    type alias Menu =
        { main : List Item
        , mainExtra : List Item
        , footer : List Item
        , footerExtra : List Item
        }

    customFromJson : Decoder Menu
    customFromJson =
        Decode.succeed Menu
            |> Pipeline.required "main_menu" decodeMenuItems
            |> Pipeline.required "main_menu_extra" decodeMenuItems
            |> Pipeline.required "footer_menu" decodeMenuItems
            |> Pipeline.required "footer_menu_extra" decodeMenuItems

-}
decodeMenuItems : Decoder (List Item)
decodeMenuItems =
    Decode.list decodeMenuItem


{-| -}
decodeMenuItem : Decoder Item
decodeMenuItem =
    Decode.succeed Item
        |> Pipeline.required "id" Id.fromJson
        |> Pipeline.required "title" Translation.fromJson
        |> Pipeline.optional "page_url" Decode.string ""


{-| -}
decodeFooter : Decoder Footer
decodeFooter =
    Decode.succeed Footer
        |> Pipeline.optional "subtitle" Translation.fromJson Translation.empty
        |> Pipeline.optional "summary" Translation.fromJson Translation.empty
        |> Pipeline.required "items" (Decode.list decodeMenuItem)
