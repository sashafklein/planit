mod = angular.module("Models")
mod.factory "Place", ($resource, BaseModel) ->
  
  class Place extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Place, json)
    @basePath: '/api/v1/places'

    url: -> "/places/#{@id}"
    name: -> @names[0]
    hasImage: -> @images.length > 0 && @images[0].url
    
  return Place

