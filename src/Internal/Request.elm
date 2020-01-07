module Internal.Request exposing
    ( delete
    , deleteTaskNoContent
    , expectJson
    , expectNoContent
    , getTask
    , postTask
    , postTaskNoContent
    , putTaskNoContent
    )

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Task exposing (Task)



-- REQUEST BUILDERS


delete : String -> Http.Expect msg -> Cmd msg
delete url expect =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = expect
        , timeout = Nothing
        , tracker = Nothing
        }


getTask : String -> Decode.Decoder a -> Task Http.Error a
getTask url decoder =
    Http.task
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , resolver = expectJson decoder
        , timeout = Nothing
        }


postTask : String -> Http.Body -> Decode.Decoder a -> Task Http.Error a
postTask url body decoder =
    Http.task
        { method = "POST"
        , headers = []
        , url = url
        , body = body
        , resolver = expectJson decoder
        , timeout = Nothing
        }


postTaskNoContent : String -> Http.Body -> Task Http.Error ()
postTaskNoContent url body =
    Http.task
        { method = "POST"
        , headers = []
        , url = url
        , body = body
        , resolver = expectNoContent
        , timeout = Nothing
        }


putTaskNoContent : String -> Http.Body -> Task Http.Error ()
putTaskNoContent url body =
    Http.task
        { method = "PUT"
        , headers = []
        , url = url
        , body = body
        , resolver = expectNoContent
        , timeout = Nothing
        }


deleteTaskNoContent : String -> Task Http.Error ()
deleteTaskNoContent url =
    Http.task
        { method = "DELETE"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , resolver = expectNoContent
        , timeout = Nothing
        }


expectNoContent : Http.Resolver Http.Error ()
expectNoContent =
    Http.stringResolver <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (Http.BadUrl url)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata _ ->
                    Err (Http.BadStatus metadata.statusCode)

                Http.GoodStatus_ _ _ ->
                    Ok ()


expectJson : Decode.Decoder a -> Http.Resolver Http.Error a
expectJson decoder =
    Http.stringResolver <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (Http.BadUrl url)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata _ ->
                    Err (Http.BadStatus metadata.statusCode)

                Http.GoodStatus_ _ body ->
                    case Decode.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (Http.BadBody (Decode.errorToString err))
