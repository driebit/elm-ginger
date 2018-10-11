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
                    Translation.toString EN translation
        ]


translation : Translation
translation =
    Translation.fromList
        [ ( NL, "Hallo" )
        , ( EN, "Hello" )
        ]
