# Changelog

# v3.1.0
* Add `getCategories`, get a category including its parents

# v3.0.0
* Rename `category` -> `getCategory`
* Rename `depiction` -> `getDepiction`
* Rename `depictions` -> `getDepictions`
* Rename `resourceQuery` -> `search`
* Rename `locationQuery` -> `searchLocation`
* Rename `Results` -> `SearchResult`
* Add common REST API request
  * `deleteResource`
  * `postEdge`
  * `deleteEdge`
  * `uploadFile`
  * `uploadFileAndPostEdge`
* Add `Request.HasContentGroup`
* Add `Request.SearchType`
* Add `Resource` alias for ResourceWith Edges
* Add `Translation.DE`
* Add `Ginger.Menu`
* Add `Translation.empty`
* Add `Translation.textNL`
* Add `Translation.htmlNL`
* Add `Translation.textEN`
* Add `Translation.htmlEN`
* Add `Id.toJson`
* Rename edgesWithPredicate -> objectsOfPredicate
* Use minimal constraint on objectsOfPredicate (`{ a | edges : List Edge }` instead of `ResourceWith Edges`)
* Deprecate `viewEither` and `viewMaybeWithDefault`, use an `if` or `case` expression instead

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
