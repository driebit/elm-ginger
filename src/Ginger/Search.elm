module Ginger.Search exposing
    ( request
    , QueryParam(..)
    , Ordering(..)
    , SortField(..)
    , queryParamsToBuilder
    )

{-|


# Search Ginger Resources

    import Ginger.Resource exposing (Category, Resource)
    import Ginger.Rest exposing (request)
    import Http

    query : String -> Http.Request Http.Error (List Resource)
    query term =
        request [ text term ]

    events : Http.Request Http.Error (List Resource)
    events =
        request
            [ upcoming
            , hasCategory Event
            , sortBy StartData Asc
            ]

@docs request

@docs QueryParam

@docs Ordering
@docs SortField

@docs queryParamsToBuilder

-}

import Ginger.Category as Category exposing (Category)
import Ginger.Resource as Resource exposing (Resource)
import Http
import Json.Decode as Decode
import Url
import Url.Builder



-- URL


absolute : List Url.Builder.QueryParameter -> String
absolute queryParams =
    Url.Builder.absolute [ "data", "search" ] queryParams



-- REQUESTS


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources []

-}
request : List QueryParam -> (Result Http.Error (List Resource) -> msg) -> Cmd msg
request queryParams msg =
    Http.get
        { url = absolute (queryParamsToBuilder queryParams)
        , expect =
            Http.expectJson msg
                (Decode.field "result" (Decode.list Resource.fromJson))
        }



-- QUERYPARAMS


{-| -}
type QueryParam
    = Category Category
    | Text String
    | Upcoming
    | Unfinished
    | SortBy SortField Ordering


{-| -}
type Ordering
    = Asc
    | Desc


{-| -}
type SortField
    = PublicationDate
    | StartDate


queryParamsToBuilder : List QueryParam -> List Url.Builder.QueryParameter
queryParamsToBuilder =
    List.map toUrlParam


toUrlParam : QueryParam -> Url.Builder.QueryParameter
toUrlParam queryParam =
    case queryParam of
        Category cat ->
            Url.Builder.string "cat" (Category.toString cat)

        Text text ->
            Url.Builder.string "text" text

        Upcoming ->
            Url.Builder.string "upcoming" "true"

        Unfinished ->
            Url.Builder.string "unfinished" "true"

        SortBy PublicationDate Asc ->
            Url.Builder.string "sort" "+rsc.publication_start"

        SortBy PublicationDate Desc ->
            Url.Builder.string "sort" "-rsc.publication_start"

        SortBy StartDate Asc ->
            Url.Builder.string "sort" "+rsc.date_start"

        SortBy StartDate Desc ->
            Url.Builder.string "sort" "-rsc.date_start"
