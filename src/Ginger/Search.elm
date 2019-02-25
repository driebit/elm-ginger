module Ginger.Search exposing
    ( Results
    , requestResources
    , requestLocations
    , QueryParam(..)
    , Ordering(..)
    , SortField(..)
    , Operator(..)
    , queryParamsToBuilder
    )

{-|


# Defintions

@docs Results


# Http

    import Ginger.Resource exposing (Category, Resource)
    import Ginger.Rest exposing (requestResources)
    import Http

    query : String -> Http.Request Http.Error (List Resource)
    query term =
        requestResources [ text term ]

    events : Http.Request Http.Error (List Resource)
    events =
        requestResources
            [ upcoming
            , hasCategory Event
            , sortBy StartData Asc
            ]

@docs requestResources
@docs requestLocations

@docs QueryParam

@docs Ordering
@docs SortField
@docs Operator

@docs queryParamsToBuilder

-}

import Ginger.Category as Category exposing (Category)
import Ginger.Resource as Resource exposing (Resource)
import Ginger.Resource.Extra as Extra exposing (Location)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Url
import Url.Builder



-- DEFINITIONS


{-| -}
type alias Results a =
    { results : List a
    , facets : Decode.Value
    , total : Int
    }



-- REQUESTS


{-|

    requestResources : Http.Request Http.Error (List Resource)
    requestResources =
        requestResources []

-}
requestResources : (Result Http.Error (Results Resource) -> msg) -> List QueryParam -> Cmd msg
requestResources msg queryParams =
    Http.get
        { url =
            Url.Builder.absolute [ "data", "search" ] <|
                queryParamsToBuilder queryParams
        , expect =
            Http.expectJson msg <|
                fromJson (Decode.list Resource.fromJson)
        }


{-| -}
requestLocations : (Result Http.Error (Results Location) -> msg) -> List QueryParam -> Cmd msg
requestLocations msg queryParams =
    Http.get
        { url =
            Url.Builder.absolute [ "data", "search", "coordinates" ] <|
                queryParamsToBuilder queryParams
        , expect =
            Http.expectJson msg <|
                fromJson (Decode.list Extra.locationFromJson)
        }



-- QUERYPARAMS


{-| -}
type QueryParam
    = HasCategory Category
    | ExcludeCategory Category
    | PromoteCategory Category
    | Facet String
    | Filter String Operator String
    | Limit Int
    | Offset Int
    | SortBy SortField Ordering
    | Text String
    | IsUnfinished
    | IsUpcoming
    | Custom String String


{-| -}
type Ordering
    = Asc
    | Desc


{-| -}
type SortField
    = PublicationDate
    | StartDate


{-| -}
type Operator
    = EQ
    | LTE
    | LT
    | GT
    | GTE
    | MatchPhrase


{-| -}
queryParamsToBuilder : List QueryParam -> List Url.Builder.QueryParameter
queryParamsToBuilder =
    List.map toUrlParam


toUrlParam : QueryParam -> Url.Builder.QueryParameter
toUrlParam queryParam =
    case queryParam of
        HasCategory cat ->
            Url.Builder.string "cat" (Category.toString cat)

        PromoteCategory cat ->
            Url.Builder.string "cat_promote" (Category.toString cat)

        ExcludeCategory cat ->
            Url.Builder.string "cat_exclude" (Category.toString cat)

        Facet facet ->
            Url.Builder.string "facet" facet

        Filter k o v ->
            Url.Builder.string "filter"
                (k ++ operatorToString o ++ v)

        Limit limit ->
            Url.Builder.int "limit" limit

        Offset offset ->
            Url.Builder.int "offset" offset

        Text text ->
            Url.Builder.string "text" text

        SortBy PublicationDate Asc ->
            Url.Builder.string "sort" "+rsc.publication_start"

        SortBy PublicationDate Desc ->
            Url.Builder.string "sort" "-rsc.publication_start"

        SortBy StartDate Asc ->
            Url.Builder.string "sort" "+rsc.date_start"

        SortBy StartDate Desc ->
            Url.Builder.string "sort" "-rsc.date_start"

        IsUpcoming ->
            Url.Builder.string "upcoming" "true"

        IsUnfinished ->
            Url.Builder.string "unfinished" "true"

        Custom k v ->
            Url.Builder.string k v


operatorToString : Operator -> String
operatorToString operator =
    case operator of
        EQ ->
            "="

        GT ->
            ">"

        GTE ->
            ">="

        LT ->
            "<"

        LTE ->
            "<="

        MatchPhrase ->
            "~"



-- DECODE


fromJson : Decode.Decoder (List a) -> Decode.Decoder (Results a)
fromJson decoder =
    Decode.succeed Results
        |> Pipeline.required "result" decoder
        |> Pipeline.required "facets" Decode.value
        |> Pipeline.required "total" Decode.int
