module Edge exposing (suite)

import Expect exposing (Expectation)
import Ginger.Edge as Edge exposing (Edge)
import Ginger.Predicate as Predicate exposing (Predicate(..))
import Test exposing (..)


suite : Test
suite =
    describe "The Ginger Edge module"
        [ test "Returns list of Int" <|
            \_ ->
                Expect.equal [ 1 ] <|
                    Edge.withPredicate Predicate.IsAbout <|
                        List.map (\( x, y ) -> Edge.wrap x y)
                            [ ( Predicate.IsAbout, 1 ), ( Predicate.HasRelation, 2 ) ]
        , test "Returns Int" <|
            \_ ->
                Expect.equal 1 <| Edge.unwrap <| Edge.wrap Predicate.IsAbout 1
        ]
