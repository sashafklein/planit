mod = angular.module("Models")
mod.factory "Location", (BaseModel, $http) ->
  
  class Location extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Location, json)
    @basePath: '/api/v1/location'

  return Location