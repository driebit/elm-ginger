module Ginger.Search exposing
    ( request
    , text
    , hasCategory
    , upcoming
    , unfinished
    , SortDirection(..)
    , SortField(..)
    , sortBy
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
@docs text
@docs hasCategory
@docs upcoming
@docs unfinished
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


absolute : List Url.Builder.QueryParameter -> String
absolute queryParams =
    Url.Builder.absolute [ "data", "search" ] queryParams



-- REQUESTS


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        requestResources []

-}
request : List Url.Builder.QueryParameter -> (Result Http.Error (List Resource) -> msg) -> Cmd msg
request queryParams msg =
    Http.get
        { url = absolute queryParams
        , expect =
            Http.expectJson msg
                (Decode.field "result" (Decode.list Resource.fromJson))
        }



-- QUERYPARAMS


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        request [ text "jimi hendrix" ]

-}
text : String -> Url.Builder.QueryParameter
text =
    Url.Builder.string "text"


{-| Specifying multiple ‘hasCategory’ arguments will do an OR on the categories.
So to select both news and event resources:

    request : Http.Request Http.Error (List Resource)
    request =
        request [ hasCategory News, hasCategory Event ]

-}
hasCategory : Category -> Url.Builder.QueryParameter
hasCategory =
    Url.Builder.string "cat" << Category.toString


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        request [ upcoming ]

-}
upcoming : Url.Builder.QueryParameter
upcoming =
    Url.Builder.string "upcoming" "true"


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        request [ unfinished ]

-}
unfinished : Url.Builder.QueryParameter
unfinished =
    Url.Builder.string "unfinished" "true"


{-|

    request : Http.Request Http.Error (List Resource)
    request =
        request [ sortBy StartData Asc ]

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
