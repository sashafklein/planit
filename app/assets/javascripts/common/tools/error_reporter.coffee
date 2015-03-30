angular.module('Common').factory 'ErrorReporter', ($http, $location, RailsEnv) ->
  
  class ErrorReporter
    @report: (hash) ->
      errorHash = _.extend( hash, page: $location.absUrl() )

      if RailsEnv.development
        hashString = _.map(errorHash, (v, k) -> "#{k}: #{v}").join("\n- ")
        console.log "Error! \n- #{hashString}"
      else
        $http.post( ErrorReporter._errorPath, error: errorHash )
          .success( (response) -> console.log 'Error reported' )

    @_errorPath: '/api/v1/errors'

  return ErrorReporter