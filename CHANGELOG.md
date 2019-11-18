# Changelog

# v3.0.0
* Add `Ginger.Menu`
* Add `Translation.empty`
* Add `Translation.textNL`
* Add `Translation.htmlNL`
* Add `Translation.textEN`
* Add `Translation.htmlEN`
* Add `Id.toJson`
* Add `Request.HasContentGroup`
* Add `Request.SearchType`
* Rename edgesWithPredicate -> objectsOfPredicate
* Use minimal constraint on objectsOfPredicate (`{ a | edges : List Edge }` instead of `ResourceWith Edges`)
* Depricate `viewEither` and `viewMaybeWithDefault`, use an `if` or `case` expression instead

# v2.2.1
* Unescape `Translation.withDefault`

# v2.2.0
* Unescape `Translation.toString`,
* Add `toStringEscaped` to access the original String
* Add `isEmpty` to check if a translation is an empty String

# v2.1.0
* Add `Ginger.Util` containing Html parsing and conditional view rendering functions

# v2.0.0
* Translation.html now returns a `List (Html msg)` instead of `Html msg`
* Rename `Resource` -> `ResourceWith`
* Rename `WithEdges` -> `Edges`
* Add missing queryparams, `HasObjectId`, `HasObjectName`, `HasSubjectId`, `HasSubjectName`

# v1.0.3
* Escape non html text.
Run `Translation.text` through html parser, remove all nodes and concat result

# v1.0.2
* Replace `elm-explorations/markdown` with `html-parser` in Translation html rendering

# v1.0.1
* Update documentation

# v1.0.0
* Inititial release
