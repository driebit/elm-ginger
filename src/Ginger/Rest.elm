module Ginger.Rest exposing
    ( requestResources
    , requestResourceById
    , requestResourceByPath
    , QueryParam(..)
    , SortField(..)
    , Ordering(..)
    , queryParamsToBuilder
    )

{-|


# Http

@docs requestResources
@docs requestResourceById
@docs requestResourceByPath


# Query parameters

    import Ginger.Resource exposing (Category, Resource)
    import Ginger.Rest exposing (requestResources)
    import Http

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources
            [ SubjectId 242
            , ObjectName "region"
            , Category Event
            ]

@docs QueryParam

@docs SortField
@docs Ordering

@docs queryParamsToBuilder

-}

import Ginger.Category as Category exposing (Category)
import Ginger.Resource as Resource exposing (Resource)
import Http
import Json.Decode as Decode
import Url
import Url.Builder



-- URL


absolute : List String -> List Url.Builder.QueryParameter -> String
absolute path queryParams =
    Url.Builder.absolute ([ "data", "resources" ] ++ path) queryParams



-- REQUESTS


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources []

-}
requestResources : (Result Http.Error (List Resource) -> msg) -> List QueryParam -> Cmd msg
requestResources msg queryParams =
    Http.get
        { url = absolute [] (queryParamsToBuilder queryParams)
        , expect = Http.expectJson msg (Decode.list Resource.fromJson)
        }


{-|

    request : Http.Request Http.Error Resource
    request =
        requestResourceById 242

-}
requestResourceById : (Result Http.Error Resource -> msg) -> Int -> Cmd msg
requestResourceById msg id =
    Http.get
        { url = absolute [ String.fromInt id ] []
        , expect = Http.expectJson msg Resource.fromJson
        }


{-|

    request : Http.Request Http.Error Resource
    request =
        requestResourceByPath "/news"

-}
requestResourceByPath : (Result Http.Error Resource -> msg) -> String -> Cmd msg
requestResourceByPath msg path =
    Http.get
        { url = absolute [ "path", Url.percentEncode path ] []
        , expect = Http.expectJson msg Resource.fromJson
        }



-- QUERYPARAMS


{-| -}
type QueryParam
    = HasCategory Category
    | HasObjectId Int
    | HasObjectName String
    | HasSubjectId Int
    | HasSubjectName String
    | SortBy SortField Ordering


{-| -}
type Ordering
    = Asc
    | Desc


{-| -}
type SortField
    = PublicationDate
    | StartDate


{-| -}
queryParamsToBuilder : List QueryParam -> List Url.Builder.QueryParameter
queryParamsToBuilder =
    List.map toUrlParam


toUrlParam : QueryParam -> Url.Builder.QueryParameter
toUrlParam queryParam =
    case queryParam of
        HasCategory cat ->
            Url.Builder.string "cat" (Category.toString cat)

        HasObjectId id ->
            Url.Builder.int "hasobject" id

        HasObjectName name ->
            Url.Builder.string "hasobject" name

        HasSubjectId id ->
            Url.Builder.int "hasobject" id

        HasSubjectName name ->
            Url.Builder.string "hassubject" name

        SortBy PublicationDate Asc ->
            Url.Builder.string "sort" "+rsc.publication_start"

        SortBy PublicationDate Desc ->
            Url.Builder.string "sort" "-rsc.publication_start"

        SortBy StartDate Asc ->
            Url.Builder.string "sort" "+rsc.date_start"

        SortBy StartDate Desc ->
            Url.Builder.string "sort" "-rsc.date_start"
