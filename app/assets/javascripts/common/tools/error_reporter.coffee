angular.module('Common').factory 'ErrorReporter', ($http, $location, RailsEnv, Flash) ->
  
  class ErrorReporter
    @silent: (res, context, hash) -> ErrorReporter._fullReport(res, context, hash) 
    @loud: (res, context, hash, msg="Something went wrong! We've been notified.") -> 
      ErrorReporter._fullReport(res, context, hash, msg)

    # First string taken as context
    # Second string taken as message
    # All hashes combined, and meta flattened
    @_fullReport: () ->
      fullHash = {}
      msg = ''

      _.forEach arguments, (arg) ->
        if typeof(arg) == 'string'
          if fullHash.context 
            if msg.length
              fullHash.extra = if fullHash.extra? then [fullHash.extra, arg].join(" -- ") else arg
            else 
              msg = arg
          else
            fullHash.context = arg
        else
          fullHash = _.extend( fullHash , arg )
      ErrorReporter._report _.extend( 
        {}
        _.omit(fullHash, 'meta', 'error')
        fullHash.meta
        { page: $location.absUrl() } 
      ), msg

    @_report: (hash, msg) ->
      if !RailsEnv.production
        hashString = _.map(hash, (v, k) -> "#{k}: #{v}").join("\n- ")
        console.log "Error! \n- #{hashString}"
      else
        $http.post( ErrorReporter._errorPath, error: hash )
          .success( (response) -> console.log 'Error reported' )

      if msg?.length
        Flash.error(msg)

      _.extend( hash, { message: msg } )

    @_errorPath: '/api/v1/errors'

  return ErrorReporter