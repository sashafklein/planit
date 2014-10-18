Mocks = undefined
BaseClass = undefined
Post = undefined

beforeEach module("BaseClass")
beforeEach module("Mocks")
beforeEach inject( (_BaseClass_, _Mocks_) ->
  BaseClass = _BaseClass_
  Mocks = _Mocks_
  Post = Mocks.Post

  return
)