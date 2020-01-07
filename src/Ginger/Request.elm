module Ginger.Request exposing
    ( resourceById
    , resourceByPath
    , resourceByName
    , deleteResource
    , postEdge
    , deleteEdge
    , uploadFile
    , uploadFileAndPostEdge
    , search
    , searchLocation
    , Results
    , QueryParam(..)
    , Ordering(..)
    , SortField(..)
    , Operator(..)
    , queryParamsToBuilder
    )

{-|


# Get

@docs resourceById
@docs resourceByPath
@docs resourceByName


## Delete

@docs deleteResource


## Edge

@docs postEdge
@docs deleteEdge


## File

@docs uploadFile
@docs uploadFileAndPostEdge


# Search

@docs search
@docs searchLocation

@docs Results

@docs QueryParam
@docs Ordering
@docs SortField
@docs Operator

@docs queryParamsToBuilder

-}

import File exposing (File)
import Ginger.Category as Category exposing (Category)
import Ginger.Id as Id exposing (ResourceId)
import Ginger.Predicate as Predicate exposing (Predicate)
import Ginger.Resource as Resource exposing (Edges, ResourceWith)
import Ginger.Resource.Extra as Extra exposing (Location)
import Http
import Internal.Request as Request
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Task exposing (Task)
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


{-| Request a resource by `ResourceId`

    Request.resourceById GotResource id

-}
resourceById : (Result Http.Error (ResourceWith Edges) -> msg) -> ResourceId -> Cmd msg
resourceById msg id =
    Http.get
        { url = absolute [ Id.toString id ] []
        , expect = Http.expectJson msg Resource.fromJsonWithEdges
        }


{-| Request a resource by its `page_path`

    Request.resourceByPath GotResource "/news"

-}
resourceByPath : (Result Http.Error (ResourceWith Edges) -> msg) -> String -> Cmd msg
resourceByPath msg path =
    Http.get
        { url = absolute [ "path", Url.percentEncode path ] []
        , expect = Http.expectJson msg Resource.fromJsonWithEdges
        }


{-| Request a resource by its uniquename

    Request.resourceByName GotResource "home"

-}
resourceByName : (Result Http.Error (ResourceWith Edges) -> msg) -> String -> Cmd msg
resourceByName msg id =
    Http.get
        { url = absolute [ id ] []
        , expect = Http.expectJson msg Resource.fromJsonWithEdges
        }


{-|

    Request.search GotEvents
        [ Request.Upcoming
        , Request.HasCategory Event
        , Request.SortBy Request.StartDate Request.Asc
        ]

-}
search :
    (Result Http.Error (Results (ResourceWith Edges)) -> msg)
    -> List QueryParam
    -> Cmd msg
search msg queryParams =
    Http.get
        { url =
            Url.Builder.absolute [ "data", "search" ] <|
                queryParamsToBuilder queryParams
        , expect =
            Http.expectJson msg <|
                fromJson (Decode.list Resource.fromJsonWithEdges)
        }


{-|

    Request.searchLocation GotLocations
        [ Request.HasCategory Person ]

-}
searchLocation : (Result Http.Error (Results Location) -> msg) -> List QueryParam -> Cmd msg
searchLocation msg queryParams =
    Http.get
        { url =
            Url.Builder.absolute [ "data", "search", "coordinates" ] <|
                queryParamsToBuilder queryParams
        , expect =
            Http.expectJson msg <|
                fromJson (Decode.list Extra.locationFromJson)
        }



-- DELETE


{-| Delete a resource by `ResourceId`

    Request.deleteResource GotDeleteResource id

-}
deleteResource :
    (Result Http.Error () -> msg)
    -> ResourceId
    -> Cmd msg
deleteResource toMsg id =
    Request.delete
        (Url.Builder.absolute [ "data", "resources", Id.toString id ] [])
        (Http.expectWhatever toMsg)



-- UPLOAD


{-| -}
uploadFile : File -> Task Http.Error ResourceId
uploadFile file =
    Request.postTask (Url.Builder.absolute [ "api", "base", "media_upload" ] [])
        (Http.multipartBody [ Http.filePart "file" file ])
        (Decode.field "rsc_id" Id.fromJson)


{-| -}
uploadFileAndPostEdge :
    { from : ResourceId
    , predicate : Predicate
    , file : File
    }
    -> Task Http.Error (ResourceWith Edges)
uploadFileAndPostEdge { from, file, predicate } =
    let
        get id =
            Request.getTask
                (Url.Builder.absolute [ "data", "resources", Id.toString id ] [])
                Resource.fromJsonWithEdges

        post fileId =
            Task.map2 (\a _ -> a)
                (get fileId)
                (postEdge
                    { from = from
                    , predicate = predicate
                    , to = fileId
                    }
                )
    in
    Task.andThen post (uploadFile file)



-- EDGE


{-| -}
postEdge :
    { from : ResourceId
    , predicate : Predicate
    , to : ResourceId
    }
    -> Task Http.Error ()
postEdge edge =
    let
        url =
            Url.Builder.absolute
                [ "data"
                , "resources"
                , Id.toString edge.from
                , "edges"
                , Predicate.toString edge.predicate
                ]
                []

        body =
            Http.jsonBody <|
                Encode.object [ ( "object", Id.toJson edge.to ) ]
    in
    Request.postTaskNoContent url body


{-| -}
deleteEdge :
    { from : ResourceId
    , predicate : Predicate
    , to : ResourceId
    }
    -> Task Http.Error ()
deleteEdge edge =
    Request.deleteTaskNoContent <|
        Url.Builder.absolute
            [ "data"
            , "resources"
            , Id.toString edge.from
            , "edges"
            , Predicate.toString edge.predicate
            , Id.toString edge.to
            ]
            []



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
            Url.Builder.int "hasobject" (Id.toInt id)

        HasObjectName name ->
            Url.Builder.string "hasobject" ("'" ++ name ++ "'")

        HasSubjectId id ->
            Url.Builder.int "hassubject" (Id.toInt id)

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
