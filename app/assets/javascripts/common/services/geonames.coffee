angular.module("Common").service "Geonames", ($http) ->
  class Geonames
    @search: (query) -> $http.get('api/v1/geonames/search', params: { query: query } )
    @point: (lat, lon) -> $http.get('api/v1/geonames/point', params: { lat: lat, lon: lon } )
  return Geonames