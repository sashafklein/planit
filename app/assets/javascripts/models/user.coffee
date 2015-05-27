mod = angular.module("Models")
mod.factory "User", (BaseModel, $http) ->
  
  class User extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(User, json)
    @basePath: '/api/v1/users'

    @trustCircle: (id) -> $http.get( "#{@objectPath(id)}/trust_circle" )

    @findPlaces: (id) -> $http.get( "#{@objectPath(id)}/places" )

    @findPlans: (id) -> $http.get( "#{@objectPath(id)}/plans" )

    @locations: (id) -> $http.get( "#{@objectPath(id)}/locations" )

  return User
      