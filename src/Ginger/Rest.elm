module Ginger.Rest exposing
    ( requestResourceById
    , requestResourceByPath
    , requestResources
    , hasCategory
    , hasObjectId
    , hasObjectName
    , hasSubjectId
    , hasSubjectName
    )

{-|


# Requests

    import Ginger.Resource exposing (Resource)
    import Ginger.Rest exposing (requestResources)
    import Http

    request : Http.Request Http.Error Resource
    request =
        requestResourceById 242

@docs requestResourceById
@docs requestResourceByPath
@docs requestResources


# Query Parameters

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

-}

import Ginger.Category as Category exposing (Category)
import Ginger.Resource as Resource exposing (Resource)
import Ginger.Resource.Decode
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
requestResources : List Url.Builder.QueryParameter -> Http.Request (List Resource)
requestResources queryParams =
    Http.get (absolute [] queryParams)
        (Decode.list Ginger.Resource.Decode.fromJson)


{-|

    request : Http.Request Http.Error Resource
    request =
        requestResourceById 242

-}
requestResourceById : Int -> Http.Request Resource
requestResourceById id =
    Http.get (absolute [ String.fromInt id ] []) Ginger.Resource.Decode.fromJson


{-|

    request : Http.Request Http.Error Resource
    request =
        requestResourceByPath "/news"

-}
requestResourceByPath : String -> Http.Request Resource
requestResourceByPath path =
    Http.get (absolute [ "path", path ] []) Ginger.Resource.Decode.fromJson



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
        requestResources [ hasObjectId 42 ]

-}
hasSubjectId : Int -> Url.Builder.QueryParameter
hasSubjectId =
    Url.Builder.int "hassubject"


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources [ hasObjectId "region" ]

-}
hasSubjectName : String -> Url.Builder.QueryParameter
hasSubjectName =
    Url.Builder.string "hassubject"
