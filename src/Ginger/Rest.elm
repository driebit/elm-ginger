module Ginger.Rest exposing
    ( requestResources
    , requestResourceById
    , requestResourceByPath
    , QueryParam(..)
    , Ordering(..)
    , SortField(..)
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

@docs Ordering
@docs SortField

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
requestResources : List QueryParam -> (Result Http.Error (List Resource) -> msg) -> Cmd msg
requestResources queryParams msg =
    Http.get
        { url = absolute [] (queryParmsToUrl queryParams)
        , expect = Http.expectJson msg (Decode.list Resource.fromJson)
        }


{-|

    request : Http.Request Http.Error Resource
    request =
        requestResourceById 242

-}
requestResourceById : Int -> (Result Http.Error Resource -> msg) -> Cmd msg
requestResourceById id msg =
    Http.get
        { url = absolute [ String.fromInt id ] []
        , expect = Http.expectJson msg Resource.fromJson
        }


{-|

    request : Http.Request Http.Error Resource
    request =
        requestResourceByPath "/news"

-}
requestResourceByPath : String -> (Result Http.Error Resource -> msg) -> Cmd msg
requestResourceByPath path msg =
    Http.get
        { url = absolute [ "path", Url.percentEncode path ] []
        , expect = Http.expectJson msg Resource.fromJson
        }



-- QUERYPARAMS


{-| -}
type QueryParam
    = Category Category
    | ObjectId Int
    | ObjectName String
    | SubjectId Int
    | SubjectName String
    | SortBy SortField Ordering


{-| -}
type Ordering
    = Asc
    | Desc


{-| -}
type SortField
    = PublicationDate
    | StartDate


queryParmsToUrl : List QueryParam -> List Url.Builder.QueryParameter
queryParmsToUrl =
    List.map toUrlParam


toUrlParam : QueryParam -> Url.Builder.QueryParameter
toUrlParam queryParam =
    case queryParam of
        Category cat ->
            Url.Builder.string "cat" (Category.toString cat)

        ObjectId id ->
            Url.Builder.int "hasobject" id

        ObjectName name ->
            Url.Builder.string "hasobject" name

        SubjectId id ->
            Url.Builder.int "hasobject" id

        SubjectName name ->
            Url.Builder.string "hassubject" name

        SortBy PublicationDate Asc ->
            Url.Builder.string "sort" "+rsc.publication_start"

        SortBy PublicationDate Desc ->
            Url.Builder.string "sort" "-rsc.publication_start"

        SortBy StartDate Asc ->
            Url.Builder.string "sort" "+rsc.date_start"

        SortBy StartDate Desc ->
            Url.Builder.string "sort" "-rsc.date_start"
