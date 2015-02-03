mod = angular.module("Models")
mod.factory "User", ($resource, BaseModel, $http) ->
  
  class User extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(User, json)
    @basePath: '/api/v1/users'

    @findPlaces: (id) -> $http.get( "#{@objectPath(id)}/places" )

  return User
      