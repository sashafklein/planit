angular.module('Common').factory 'API', ($http) ->
  
  fullPath = (path) -> "/api/v1/#{path}"

  return {
    get: (path, data={}) -> $http.get( fullPath(path), params: data )
    post: (path, data={}) -> $http.get( fullPath(path), data )
  }