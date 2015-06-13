angular.module("SPA").service "SPPlaces", (CurrentUser, User, Place, ErrorReporter, SPPlace) ->
  class SPPlaces

    constructor: ( userId ) ->
      self = @
      self.places = {}
      self.clustersFetched = []
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