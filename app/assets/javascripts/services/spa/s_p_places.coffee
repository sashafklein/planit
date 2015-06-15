angular.module("SPA").service "SPPlaces", (CurrentUser, User, Mark, Place, RailsEnv, ErrorReporter, SPPlace) ->
  class SPPlaces

    constructor: ( userId ) ->
      self = @
      self.places = {}
      self.clustersFetched = []
      self.addingMark = []
      # self.usersFetched = []
      # @fetchUsersPlaces( userId )

    _pusher: if RailsEnv.test then @_fakePusher else new Pusher( RailsEnv.pusher_key ) 
    _fakePusher:
      subscribe: -> 
        bind: -> alert("Pusher disabled in test mode")

    # fetchUsersPlaces: ( userId ) ->
    #   self = @
    #   return unless userId
    #   return unless self.fetchingUserPlaces != userId
    #   self.fetchingUserPlaces = userId
    #   User.marks( userId )
    #     .success (responses) -> 
    #       _.forEach responses, (r) -> 
    #         self.places[r.id] = new SPPlace( r ) unless self.places[r.id]
    #         self.places[r.id].users = [] unless self.places[r.id].users
    #         self.places[r.id].users.push userId
    #       self.usersFetched.push userId
    #       self.fetchingUserPlaces = null
    #     .error (response) -> 
    #       self.fetchingUserPlaces = null
    #       ErrorReporter.silent( response, 'SinglePagePlaces fetch Users Places', user_id: userId )

    # usersPlaces: ( userId ) ->
    #   self = @ 
    #   return unless userId
    #   userPlacesFound = _.filter( self.places, (p) -> _.include( p.users, userId ) )
    #   return userPlacesFound if _.include( self.usersFetched , parseInt( userId ) )
    #   self.fetchUsersPlaces( userId ) unless self.fetchingUserPlaces != userId
    #   return []

    addMark: ( fsOption, delay=true ) -> 
      self = @
      return unless foursquare_id = fsOption['foursquare_id']
      if place_id = fsOption['id'] && self.places[ place_id ]?['savers']
        self.places[ place_id ]['savers'].push CurrentUser.id
      else if foursquare_id = fsOption['foursquare_id']
        self.places[ foursquare_id ] = fsOption
        self.places[ foursquare_id ]['savers'] = [] unless self.places[ foursquare_id ]?['savers']
        self.places[ foursquare_id ]['savers'].push CurrentUser.id
      if delay && !RailsEnv.test
        @_setAddMarkSuccess( fsOption )
      else
        Mark.addFromPlaceData( fsOption )
          .success (response) -> 
            self._afterAddMarkSuccess( response )
          .error (response) -> ErrorReporter.silent( response, "SPPlace addMark", { place_data: placeData } )

    _clearFoursquarePlaceholder: ( foursquare_id ) ->
      console.log "clear"
      self = @
      if self.places[ foursquare_id ]
        delete self.places[ foursquare_id ]
      self.addingMark.splice( self.addingMark.indexOf( foursquare_id ) , 1 ) unless self.addingMark.indexOf( foursquare_id ) == -1
      self._pusher.unsubscribe( "add-mark-from-place-data-#{ foursquare_id }" )

    _afterAddMarkSuccess: ( response ) ->
      console.log "success"
      self = @
      self._clearFoursquarePlaceholder( response.foursquare_id )
      self.places[ response.id ] = response unless self.places[ response.id ]
      self.places[ response.id ].savers.push CurrentUser.id

    _setAddMarkSuccess: ( fsOption ) ->
      console.log "setting"
      self = @
      return unless foursquare_id = fsOption['foursquare_id']
      self.addingMark.push foursquare_id
      channel = @_pusher.subscribe( "add-mark-from-place-data-#{ foursquare_id }" )
      Mark.addFromPlaceData( fsOption )
        .success (response) -> null
        .error (response) ->
          self._clearFoursquarePlaceholder( foursquare_id )
          ErrorReporter.silent( response, "SPPlace addMark", { place_data: fsOption } )
      channel.bind 'added', ( response ) -> self._afterAddMarkSuccess( response )

    fetchClustersPlaces: ( clusterId ) ->
      self = @
      return unless clusterId
      return if self.fetchingClustersPlaces == clusterId
      self.fetchingClustersPlaces = clusterId
      Place.inCluster( clusterId )
        .success (responses) -> 
          _.forEach responses, (r) -> 
            self.places[r.id] = new SPPlace( r ) unless self.places[r.id]
            self.places[r.id].note = self.places[r.id].notes[ CurrentUser.id ] if self.places[r.id].notes && self.places[r.id].notes[ CurrentUser.id ]
            self.places[r.id].noteOriginal = self.places[r.id].note if self.places[r.id].note
            delete self.places[r.id].notes[ CurrentUser.id ]
          self.clustersFetched.push parseInt( clusterId )
          self.fetchingClusterPlaces = null
        .error (response) -> 
          self.fetchingClusterPlaces = null
          ErrorReporter.silent( response, 'SinglePagePlaces fetch Clusters Places', cluster_id: clusterId )

    clustersPlaces: ( clusterId ) ->
      self = @
      return unless clusterId
      clustersPlacesFound = _.filter( self.places, (p) -> parseInt( p.clusterId ) == parseInt( clusterId ) )
      return clustersPlacesFound if _.include( self.clustersFetched , parseInt( clusterId ) )
      self.fetchClustersPlaces( clusterId ) unless self.fetchingClustersPlaces == clusterId
      return []

  return SPPlaces