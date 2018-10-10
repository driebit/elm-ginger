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
                    Edge.withPredicate Predicate.About <|
                        List.map (\( x, y ) -> Edge.const x y)
                            [ ( Predicate.About, 1 ), ( Predicate.Relation, 2 ) ]
        , test "Returns Int" <|
            \_ ->
                Expect.equal 1 <| Edge.unwrap <| Edge.const Predicate.About 1
        ]
