mod = angular.module("Models")
mod.factory "Place", ($resource, BaseModel) ->
  
  class Place extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Place, json)
    @basePath: '/api/v1/places'

  return Place
      