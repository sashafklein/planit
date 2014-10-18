angular.module("Mocks")
  .factory "Post", [ 'BaseClass', (BaseClass) ->
    Post = (attributes) -> 
      this.id = attributes.id
      
    Post.inherits(BaseClass.Base)
    return Post
  ]