# Changelog

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
