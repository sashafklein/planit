angular.module("Common").service "Foursquare", ($http) ->
  class Foursquare
    @search: (near, query) -> $http.get('api/v1/foursquare/search', params: { near: near, query: query } )

  return Foursquare