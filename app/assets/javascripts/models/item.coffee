mod = angular.module("Models")
mod.factory "Item", ($resource, BaseModel) ->
  
  class Item extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Item, json)
    @basePath: '/api/v1/items'

  return Item
      