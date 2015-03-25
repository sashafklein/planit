mod = angular.module("Models")
mod.factory "Mark", (BaseModel, $http) ->
  
  class Mark extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Mark, json)
    @basePath: '/api/v1/marks'
    
  return Mark