angular.module("Services").service "Background", (RailsEnv, ErrorReporter) ->
  
  # Example BG Job

  # new Background(
  #   name: 'unique-channel-name'
  #   eventName: 'added'
  #   action: -> Class.makeRequest( someData )
  #   onSuccess: (response) -> 
  #     scope.removePlaceholder( response )
  #     scope.classObjects.push( response )
  #   onEnqueue: (response) -> scope.setPlaceholder( response )
  #   onInstantSuccess: (response) -> console.log("Job executed directly!")
  #   onDelaySuccess: (response) -> console.log("Asynchronous execution complete!")
  # ).run() # Runs the job synchronously or asynchronously, as demanded by the env. Uses the above hooks
  
  # Additional options: onEnqueueFailureParams, onActionFailureParams, actionFailureVolume

  class Background
    
    constructor: (options) -> 
      self = @
      _.forEach options, (value, key) -> self[key] = value
      @eventName ||= 'done'

    run: ->
      self = @
      if RailsEnv.test
        self.action()
          .success (data) ->
            self.onSuccess?( data )
            self.onInstantSuccess?( data )
          .error (data) ->
            params = _.extend( self.errorParams , self.onActionFailureParams || {} )
            self._actionError( data, "Background run instant", params )
      else
        self._subscribe()
        self._bindEvent()
        self.action()
          .success( (data) -> self.onEnqueue?( data ) )
          .error ( data ) ->
            params = _.extend( self.errorParams , self.onEnqueueFailureParams || {} )
            self._actionError( data, "Background run delay", params )

    _pusher: if RailsEnv.test then @_fakePusher else new Pusher( RailsEnv.pusher_key ) 
    _fakePusher:
      subscribe: -> 
        bind: -> alert("Pusher disabled in test mode")

    _subscribe: -> @channel = @_pusher.subscribe( @name )
    _unsubscribe: -> @_pusher.unsubscribe( @name )
    _actionError: (data, string, moreData) -> ErrorReporter[ @actionFailureVolume || 'silent' ]( data, string, moreData )
    _bindEvent: ->    
      self = @
      self.channel.bind self.eventName, (data) ->
        self.onSuccess?( data )
        self.onDelaySuccess?( data )
        self._unsubscribe()

    _errorParams: { env: RailsEnv.env, name: self.name, event_name: self.eventName }

  return Background