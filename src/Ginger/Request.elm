module Ginger.Request exposing
    ( resourceById
    , resourceByPath
    , resourceByName
    , resourceQuery
    , locationQuery
    , Results
    , QueryParam(..)
    , Ordering(..)
    , SortField(..)
    , Operator(..)
    , queryParamsToBuilder
    )

{-|


# Requests

Here are some examples of how you might get Ginger resources.

    import Ginger.Request as Request
        exposing
            ( Ordering(..)
            , QueryParam(..)
            , SortField(..)
            )

    query : Cmd Msg
    query =
        Request.resourceQuery GotSearchResults
            [ Text "amsterdam" ]

    events : Cmd Msg
    events =
        Request.resourceQuery GotEvents
            [ Upcoming
            , HasCategory Event
            , SortBy StartDate Asc
            ]

@docs resourceById
@docs resourceByPath
@docs resourceByName
@docs resourceQuery
@docs locationQuery


# Search

@docs Results

@docs QueryParam
@docs Ordering
@docs SortField
@docs Operator

@docs queryParamsToBuilder

-}

import Ginger.Category as Category exposing (Category)
import Ginger.Id exposing (ResourceId)
import Ginger.Resource as Resource exposing (Edges, ResourceWith)
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

    request : (Http.Request Http.Error Resource -> msg) -> Ginger.Id.ResourceId -> Cmd msg
    request toMsg id =
        Request.resourceById toMsg id

-}
resourceById : (Result Http.Error (ResourceWith Edges) -> msg) -> ResourceId -> Cmd msg
resourceById msg id =
    Http.get
        { url = absolute [ Ginger.Id.toString id ] []
        , expect = Http.expectJson msg Resource.fromJsonWithEdges
        }


{-|

    request : (Http.Request Http.Error Resource -> msg) -> Cmd msg
    request toMsg =
        Request.resourceByPath toMsg "/news"

-}
resourceByPath : (Result Http.Error (ResourceWith Edges) -> msg) -> String -> Cmd msg
resourceByPath msg path =
    Http.get
        { url = absolute [ "path", Url.percentEncode path ] []
        , expect = Http.expectJson msg Resource.fromJsonWithEdges
        }


{-|

    request : (Http.Request Http.Error Resource -> msg) -> Cmd msg
    request toMsg =
        Request.resourceByName toMsg "home"

-}
resourceByName : (Result Http.Error (ResourceWith Edges) -> msg) -> String -> Cmd msg
resourceByName msg id =
    Http.get
        { url = absolute [ id ] []
        , expect = Http.expectJson msg Resource.fromJsonWithEdges
        }


{-|

    request : (Http.Request Http.Error Resource -> msg) -> Cmd msg
    request toMsg =
        Request.resourceQuery toMsg [ Text "amsterdam" ]

-}
resourceQuery :
    (Result Http.Error (Results (ResourceWith Edges)) -> msg)
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


{-| Some of these params only work if `mod_elasticsearch` is enabled
-}
type QueryParam
    = HasContentGroup String
    | ExcludeCategory Category
    | Facet String
    | Filter String Operator String
    | HasCategory Category
    | HasObjectId ResourceId
    | HasObjectName String
    | HasSubjectId ResourceId
    | HasSubjectName String
    | IsUnfinished
    | IsUpcoming
    | Limit Int
    | Offset Int
    | PromoteCategory Category
    | SortBy SortField Ordering
    | Text String
    | SearchType String
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


{-| Convert this modules `QueryParm` to elm/url `QueryParameter` values
to use with Url.Builder.
-}
queryParamsToBuilder : List QueryParam -> List Url.Builder.QueryParameter
queryParamsToBuilder =
    List.map toUrlParam


toUrlParam : QueryParam -> Url.Builder.QueryParameter
toUrlParam queryParam =
    case queryParam of
        HasContentGroup group ->
            Url.Builder.string "content_group" group

        HasCategory cat ->
            Url.Builder.string "cat" (Category.toString cat)

        HasObjectId id ->
            Url.Builder.int "hasobject" (Ginger.Id.toInt id)

        HasObjectName name ->
            Url.Builder.string "hasobject" ("'" ++ name ++ "'")

        HasSubjectId id ->
            Url.Builder.int "hassubject" (Ginger.Id.toInt id)

        HasSubjectName name ->
            Url.Builder.string "hassubject" ("'" ++ name ++ "'")

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

        SearchType type_ ->
            Url.Builder.string "type" type_

        SortBy PublicationDate Asc ->
            Url.Builder.string "sort" "rsc.publication_start"

        SortBy PublicationDate Desc ->
            Url.Builder.string "sort" "-rsc.publication_start"

        SortBy StartDate Asc ->
            Url.Builder.string "sort" "rsc.pivot_date_start"

        SortBy StartDate Desc ->
            Url.Builder.string "sort" "-rsc.pivot_date_start"

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
