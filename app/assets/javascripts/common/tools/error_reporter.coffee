angular.module('Common').factory 'ErrorReporter', ($http, $location, RailsEnv, Flash) ->
  
  class ErrorReporter
    @report: (hash, msg) ->
      errorHash = _.extend( hash, page: $location.absUrl() )

      if RailsEnv.development
        hashString = _.map(errorHash, (v, k) -> "#{k}: #{v}").join("\n- ")
        console.log "Error! \n- #{hashString}"
      else
        $http.post( ErrorReporter._errorPath, error: errorHash )
          .success( (response) -> console.log 'Error reported' )

      if msg?.length
        Flash.error(msg)

    @defaultReport: (hash) -> ErrorReporter.report(hash, "Something went wrong! We've been notified.")
    @fullReport: (res, context, hash, msg) ->
      ErrorReporter.report _.extend(hash, { msg: res.message, code: res.code, context: context, rails_controller: res.controller }), msg

    @defaultFull: (res, context, hash) -> ErrorReporter.fullReport(res, context, hash, "Something went wrong! We've been notified.")

    @_errorPath: '/api/v1/errors'

  return ErrorReporter