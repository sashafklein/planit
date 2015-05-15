mod = angular.module("Models")
mod.factory "Item", (BaseModel, Mark) ->
  
  class Item extends BaseModel

    constructor: (_properties) ->
      properties = _.clone(_properties)
      @mark = @extractHasOneRelation(Mark, properties, 'mark')

      _.extend(this, properties)

    @class: "Item"
    class: Item.class
    
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Item, json)
    @basePath: '/api/v1/items'

    place: -> @mark?.place
    placeHref: -> @mark?.place?.fs_href
    
  return Item
      