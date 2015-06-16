angular.module("SPA").service "SPPlaces", (CurrentUser, User, Mark, Place, RailsEnv, ErrorReporter, SPPlace, Background) ->
  class SPPlaces

    constructor: ( userId ) ->
      self = @
      self.places = {}
      self.clustersFetched = []
      self.addingMark = []
      self.currentClusterId = null
      # self.usersFetched = []
      # @fetchUsersPlaces( userId )

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

    addMark: ( fsOption ) -> 
      return unless foursquare_id = fsOption.foursquare_id
      self = @
      
      place = null
      unless place = self.places[ fsOption.id ]
        place = self.places[ fsOption.foursquare_id ] = fsOption
        place.clusterId = self.currentClusterId

      place.savers = if place.savers? then _.uniq( place.savers.concat( CurrentUser.id ) ) else [ CurrentUser.id ]
      
      new Background(
        name: "add-mark-from-place-data-#{ foursquare_id }"
        eventName: 'added'
        action: -> Mark.addFromPlaceData( fsOption )
        onSuccess: (response) -> self._afterAddMarkSuccess( response )
        onEnqueueFailure: -> self._clearFoursquarePlaceholder( foursquare_id )
        onActionFailureParams: { place_data: fsOption }
      ).run()

    _clearFoursquarePlaceholder: ( foursquare_id ) ->
      delete @places[ foursquare_id ] if @places[ foursquare_id ]
      @addingMark.splice( @addingMark.indexOf( foursquare_id ) , 1 ) unless @addingMark.indexOf( foursquare_id ) == -1

    _afterAddMarkSuccess: ( response ) ->
      @_clearFoursquarePlaceholder( response.foursquare_id )
      @places[ response.id ] = response unless @places[ response.id ]
      @places[ response.id ].savers.push CurrentUser.id

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