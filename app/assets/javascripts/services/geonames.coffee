angular.module("Services").service "Geonames", ($http) ->
  class Geonames
    @search: (query) -> $http.get('api/v1/geonames/search', params: { query: query } )
    @point: (lat, lon) -> $http.get('api/v1/geonames/point', params: { lat: lat, lon: lon } )
    @find: (id) -> $http.get('api/v1/geonames/find', params: { id: id } ) 
  return Geonames