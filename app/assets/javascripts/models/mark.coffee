mod = angular.module("Models")
mod.factory "Mark", (BaseModel, $http) ->
  
  class Mark extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Mark, json)
    @basePath: '/api/v1/marks'
    
    choose: (place_option_id) ->
      $http.post( "#{ @objectPath() }/choose", { place_option_id: place_option_id } )

  return Mark