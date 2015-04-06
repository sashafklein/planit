mod = angular.module("Models")
mod.factory "User", (BaseModel, $http) ->
  
  class User extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(User, json)
    @basePath: '/api/v1/users'

    @findPlaces: (id) -> $http.get( "#{@objectPath(id)}/places" )

    @findPlans: (id) -> $http.get( "#{@objectPath(id)}/plans" )

  return User
      