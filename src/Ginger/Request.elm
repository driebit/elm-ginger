module Ginger.Request exposing
    ( Results
    , resourceById
    , resourceByPath
    , resourceByName
    , resourceQuery
    , locationQuery
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

@docs resourceById
@docs resourceByPath
@docs resourceByName
@docs resourceQuery
@docs locationQuery


# Http

    import Ginger.Resource exposing (Category, Resource)
    import Ginger.Rest exposing (resourceQuery)
    import Http

    query : String -> Http.Request Http.Error (List Resource)
    query term =
        resourceQuery [ text term ]

    events : Http.Request Http.Error (List Resource)
    events =
        resourceQuery
            [ upcoming
            , hasCategory Event
            , sortBy StartData Asc
            ]

@docs QueryParam

@docs Ordering
@docs SortField
@docs Operator

@docs queryParamsToBuilder

-}

import Ginger.Category as Category exposing (Category)
import Ginger.Resource as Resource exposing (Resource, WithEdges)
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



-- URL


absolute : List String -> List Url.Builder.QueryParameter -> String
absolute path queryParams =
    Url.Builder.absolute ([ "data", "resources" ] ++ path) queryParams



-- REQUESTS


{-|

    request : Http.Request Http.Error Resource
    request =
        resourceById 242

-}
resourceById : (Result Http.Error (Resource WithEdges) -> msg) -> Int -> Cmd msg
resourceById msg id =
    Http.get
        { url = absolute [ String.fromInt id ] []
        , expect = Http.expectJson msg Resource.fromJsonWithEdges
        }


{-|

    request : Http.Request Http.Error Resource
    request =
        resourceByPath "/news"

-}
resourceByPath : (Result Http.Error (Resource WithEdges) -> msg) -> String -> Cmd msg
resourceByPath msg path =
    Http.get
        { url = absolute [ "path", Url.percentEncode path ] []
        , expect = Http.expectJson msg Resource.fromJsonWithEdges
        }


{-|

    request : Http.Request Http.Error Resource
    request =
        resourceByName "home"

-}
resourceByName : (Result Http.Error (Resource WithEdges) -> msg) -> String -> Cmd msg
resourceByName msg id =
    Http.get
        { url = absolute [ id ] []
        , expect = Http.expectJson msg Resource.fromJsonWithEdges
        }


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        resourceQuery []

-}
resourceQuery :
    (Result Http.Error (Results (Resource WithEdges)) -> msg)
    -> List QueryParam
    -> Cmd msg
resourceQuery msg queryParams =
    Http.get
        { url =
            Url.Builder.absolute [ "data", "search" ] <|
                queryParamsToBuilder queryParams
        , expect =
            Http.expectJson msg <|
                fromJson (Decode.list Resource.fromJsonWithEdges)
        }


{-| -}
locationQuery : (Result Http.Error (Results Location) -> msg) -> List QueryParam -> Cmd msg
locationQuery msg queryParams =
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
