# Changelog

# v2.2.0
*  Escape `Translation.toString` and add `toStringEscaped` to access the original String

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
