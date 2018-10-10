module Translation exposing (suite)

import Expect exposing (Expectation)
import Ginger.Translation as Translation exposing (Language(..), Translation)
import Test exposing (..)


suite : Test
suite =
    describe "The Ginger Translation module"
        [ test "Returns a translated string" <|
            \_ ->
                Expect.equal "Hello" <|
                    Translation.toString EN translationA
        , test "Apply a function to all translated values" <|
            \_ ->
                Expect.equal translationB <|
                    Translation.map (\x -> x ++ "!") translationA
        ]


translationA : Translation
translationA =
    Translation.fromList
        [ ( NL, "Hallo" )
        , ( EN, "Hello" )
        ]


translationB : Translation
translationB =
    Translation.fromList
        [ ( NL, "Hallo!" )
        , ( EN, "Hello!" )
        ]
