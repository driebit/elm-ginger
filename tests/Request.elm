module Request exposing (suite)

import Expect exposing (Expectation)
import Ginger.Category as Category
import Ginger.Request exposing (..)
import Test exposing (..)
import Url.Builder


suite : Test
suite =
    describe "Convert queryparams to string"
        [ test "Convert to the correct key value pairs" <|
            \_ ->
                Expect.equal expectedParams <|
                    Url.Builder.toQuery <|
                        queryParamsToBuilder
                            [ HasCategory Category.Text
                            , ExcludeCategory Category.Article
                            , Facet "foo"
                            , Filter "foo" LTE "bar"
                            , HasObjectName "foo"
                            , HasSubjectName "bar"
                            , IsUnfinished
                            , IsUpcoming
                            , Limit 1
                            , Offset 2
                            , PromoteCategory Category.News
                            , SortBy StartDate Asc
                            , Text "hola"
                            , Custom "foo" "bar"
                            ]
        ]


expectedParams : String
expectedParams =
    String.join "&"
        [ "?cat=text"
        , "cat_exclude=article"
        , "facet=foo"
        , "filter=foo%3C%3Dbar"
        , "hasobject='foo'"
        , "hassubject='bar'"
        , "unfinished=true"
        , "upcoming=true"
        , "limit=1"
        , "offset=2"
        , "cat_promote=news"
        , "sort=rsc.pivot_date_start"
        , "text=hola"
        , "foo=bar"
        ]
