module Ginger.Rest exposing
    ( requestResourceById
    , requestResourceByPath
    , requestResources
    , hasCategory
    , hasObjectId
    , hasObjectName
    , hasSubjectId
    , hasSubjectName
    , SortDirection(..)
    , SortField(..)
    , sortBy
    )

{-|


# Http

    import Ginger.Resource exposing (Resource)
    import Ginger.Rest exposing (requestResources)
    import Http

    request : Http.Request Http.Error Resource
    request =
        requestResourceById 242

@docs requestResourceById
@docs requestResourceByPath
@docs requestResources


# Query parameters

    import Ginger.Resource exposing (Category, Resource)
    import Ginger.Rest exposing (requestResources)
    import Http

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources
            [ hasSubjectId 242
            , hasObjectName "region"
            , hasCategory Event
            ]

@docs hasCategory
@docs hasObjectId
@docs hasObjectName

@docs hasSubjectId
@docs hasSubjectName
@docs SortDirection
@docs SortField
@docs sortBy

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
requestResources : List Url.Builder.QueryParameter -> (Result Http.Error (List Resource) -> msg) -> Cmd msg
requestResources queryParams msg =
    Http.get
        { url = absolute [] queryParams
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


{-| Specifying multiple ‘hasCategory’ arguments will do an OR on the categories.
So to select both news and event resources:

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources [ hasCategory News, hasCategory Event ]

-}
hasCategory : Category -> Url.Builder.QueryParameter
hasCategory =
    Url.Builder.string "cat" << Category.toString


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources [ hasObjectId 42 ]

-}
hasObjectId : Int -> Url.Builder.QueryParameter
hasObjectId =
    Url.Builder.int "hasobject"


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources [ hasObjectName "region" ]

-}
hasObjectName : String -> Url.Builder.QueryParameter
hasObjectName =
    Url.Builder.string "hasobject"


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources [ hasSubjectId 42 ]

-}
hasSubjectId : Int -> Url.Builder.QueryParameter
hasSubjectId =
    Url.Builder.int "hassubject"


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources [ hasSubjectName "region" ]
            requestResources
            [ HasSubjectName "region" ]

-}
hasSubjectName : String -> Url.Builder.QueryParameter
hasSubjectName =
    Url.Builder.string "hassubject"


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources [ sortBy "+rsc.id" ]

-}
sortBy : SortField -> SortDirection -> Url.Builder.QueryParameter
sortBy field direction =
    let
        format =
            case direction of
                Asc ->
                    "+rsc."

                Desc ->
                    "-rsc."

        field_ =
            case field of
                PublicationDate ->
                    "publication_start"

                StartDate ->
                    "date_start"
    in
    Url.Builder.string "sort" (format ++ field_)


{-| -}
type SortDirection
    = Asc
    | Desc


{-| -}
type SortField
    = PublicationDate
    | StartDate
