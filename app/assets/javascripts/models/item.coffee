    mod = angular.module("Models")
    mod.factory "Item", ($resource, Base) ->
      
      class Item extends Base
        @generateFromJSON: (json) -> Base.generateFromJSON(Item, json)
        @basePath: '/api/v1/items'

      return Item
      