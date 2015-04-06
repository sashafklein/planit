mod = angular.module("Models")
mod.factory "Plan", (BaseModel, $http) ->
  
  class Plan extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Plan, json)
    @basePath: '/api/v1/plans'

    @findPlaces: (id) -> $http.get( "#{@objectPath(id)}/places" )

    addItems: (place_ids) -> $http.post( "#{@objectPath()}/add_items", { place_ids: place_ids } ) 
    destroyItems: (place_ids) -> $http.post( "#{@objectPath()}/destroy_items", { place_ids: place_ids } ) 

  return Plan