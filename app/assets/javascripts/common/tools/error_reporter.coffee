angular.module('Common').factory 'ErrorReporter', ($http, $location) ->
  
  class ErrorReporter
    @report: (hash) ->
      $http.post( ErrorReporter._errorPath, 
        error: _.extend(hash, page: $location.absUrl() )
      ).success( (response) -> console.log 'Error reported' )

    @_errorPath: '/api/v1/errors'

  return ErrorReporter