module Ginger.Resource exposing
    ( ResourceData
    , Edge
    , CategoryList
    , ResourceDataConstructor
    , getCategory
    , getCategories
    , firstDepictionOfClass
    , depictionsOfClass
    , objectsOfPredicate
    , resourceDataPipeline
    , edgeFromJson
    , categoryListFromJson
    )

{-|


# Definitions

@docs ResourceData
@docs Edge
@docs CategoryList
@docs ResourceDataConstructor


# Access data

@docs getCategory
@docs getCategories
@docs firstDepictionOfClass
@docs depictionsOfClass
@docs objectsOfPredicate


# Decode

@docs resourceDataPipeline
@docs edgeFromJson
@docs categoryListFromJson

-}

import Ginger.Id as Id exposing (ResourceId)
import Ginger.Media as Media exposing (Media)
import Ginger.Translation as Translation exposing (Translation)
import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Time


{-| Standard Ginger Resource data

Fields that often have different types between sites are omitted, so sites can add them themselves
by letting this record extend a record that contains the fields.

It is recommended to have a separate record for the `edges` field, because it is useful to know at compile time whether a resource's edges have been fetched or not.
For example, you could have:

    type alias Resource =
        SiteData (ResourceData Edges)

    type alias DisconnectedResource =
        SiteData (ResourceData {})

    type alias SiteData a =
        { a
            | categories : CategoryList Category
            , blocks : List Block
        }

    type alias Edges =
        { edges : List (Edge Predicate DisconnectedResource)
        }

-}
type alias ResourceData a =
    { a
        | id : ResourceId
        , title : Translation
        , body : Translation
        , subtitle : Translation
        , summary : Translation
        , path : String
        , name : Maybe String
        , publicationDate : Maybe Time.Posix
        , media : Media
        , properties : Decode.Value
    }


{-| A "trail" of categories from a leaf to the root
-}
type alias CategoryList category =
    { leaf : category
    , parents : List category
    }


{-| An edge to a different resource via a specific predicate
-}
type alias Edge predicate resource =
    { predicate : predicate
    , resource : resource
    }



-- QUERY


{-| Return all resources with a given predicate.
-}
objectsOfPredicate : predicate -> { a | edges : List (Edge predicate resource) } -> List resource
objectsOfPredicate predicate resource =
    List.map .resource <|
        List.filter ((==) predicate << .predicate) resource.edges


{-| Get the category of a resource.

Every resource has a category, and that category can be part of a category tree.
For instance, the `news` category belongs to the category tree `text > news`.
This function will return only the leaf category,
so in this case `news`, but not its parent `text`.

-}
getCategory : { a | category : CategoryList category } -> category
getCategory =
    .leaf << .category


{-| Get all the categories of the resource, starting from the parent
category and ending with the leaf. For example, in the case of a
`news` resource, it will return [`text`, `news`].
-}
getCategories : { a | category : CategoryList category } -> List category
getCategories resource =
    List.reverse (resource.category.leaf :: resource.category.parents)


{-| The image url of the resource's depiction.

Returns the image url if there is a depiction _and_ the mediaclass exists.

-}
firstDepictionOfClass : Media.MediaClass -> List (ResourceData a) -> Maybe String
firstDepictionOfClass mediaClass =
    List.head << depictionsOfClass mediaClass


{-| The image urls of the resource's depictions

Returns a list of image urls if there is a depiction _and_ the mediaclass exists.

-}
depictionsOfClass : Media.MediaClass -> List (ResourceData a) -> List String
depictionsOfClass mediaClass =
    List.filterMap (Media.imageUrl mediaClass << .media)



-- DECODE


{-| The type for a function that can be used to construct an actual resource.

For example:

    resourceFromJson : Decode.Decoder (ResourceData { category : CategoryList Category })
    resourceFromJson =
        let
            resourceConstructor a b c d e f g h i j k =
                { id = a
                , title = b
                , body = c
                , subtitle = d
                , summary = e
                , path = f
                , name = g
                , publicationDate = h
                , media = i
                , properties = j
                , category = k
                }
        in
        Decode.succeed resourceConstructor
            |> Resource.resourceDataPipeline
            |> Pipeline.required "categories" (Resource.categoryListFromJson Category.fromJson)

-}
type alias ResourceDataConstructor a =
    ResourceId
    -> Translation
    -> Translation
    -> Translation
    -> Translation
    -> String
    -> Maybe String
    -> Maybe Time.Posix
    -> Media
    -> Decode.Value
    -> a


{-| A decoding pipeline for standard resource data.
See `ResourceDataConstructor` for a usage example.
-}
resourceDataPipeline : Decoder (ResourceDataConstructor a) -> Decoder a
resourceDataPipeline =
    Pipeline.required "id" Id.fromJson
        >> Pipeline.required "title" Translation.fromJson
        >> Pipeline.required "body" Translation.fromJson
        >> Pipeline.required "subtitle" Translation.fromJson
        >> Pipeline.required "summary" Translation.fromJson
        >> Pipeline.required "path" Decode.string
        >> Pipeline.optional "name" (Decode.map Just Decode.string) Nothing
        >> Pipeline.required "publication_date" (Decode.maybe Iso8601.decoder)
        >> Pipeline.optional "media" Media.fromJson Media.empty
        >> Pipeline.required "properties" Decode.value


{-| -}
categoryListFromJson : Decoder category -> Decoder (CategoryList category)
categoryListFromJson categoryFromJson =
    Decode.list categoryFromJson
        |> Decode.andThen checkCategoryList


checkCategoryList : List category -> Decoder (CategoryList category)
checkCategoryList list =
    case List.reverse list of
        [] ->
            Decode.fail "An array with one or more elements."

        x :: xs ->
            Decode.succeed { leaf = x, parents = xs }


{-| -}
edgeFromJson : Decoder predicate -> Decoder resource -> Decoder (Edge predicate resource)
edgeFromJson predicateFromJson resourceFromJson =
    Decode.succeed Edge
        |> Pipeline.required "predicate_name" predicateFromJson
        |> Pipeline.required "resource" resourceFromJson
