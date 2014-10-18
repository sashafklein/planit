angular.module("Mocks", ["BaseClass"])
  .factory "Mocks", [ "Post", (Post) ->
    return Post: Post
  ]