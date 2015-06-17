angular.module("SPA").service "SPLocations", (User, Plan, Location, Geonames, QueryString, ErrorReporter) ->
  class SPLocations

    constructor: ( userId ) ->
      self = @
      self.locations = {}
      self.clusters = {}
      self.usersQueried = []
      self.countriesQueried = []
      self.countriesClustersFetched = []
      self.locationsQueried = []
      @fetchUsersLocations( userId )

    clusters: ->
      self = @
      return _.filter( self.locations, (l) -> l.isCluster )

    clustersInCountry: ( countryId ) ->
      self = @
      return _.filter( self.clusters, (c) -> parseInt( c.countryId ) == parseInt( countryId ) )

    setLocation: ( geonameObj ) ->
      self = @
      return unless geonameObj && geonameId = geonameObj?.geonameId
      unless self.locations[ geonameId ]?.clusterId || _.include( self.locationsQueried, parseInt(geonameId) )
        self.locationsQueried.push parseInt(geonameId)
        Location.findWithGeonameObject( geonameObj )
          .success (response) ->
            if response
              self.locations[ parseInt( response.geonameId ) ] = response
              self.clusters[ parseInt( response.clusterId ) ] = { name: response.clusterName, lat: response.clusterLat, lon: response.clusterLon, id: response.clusterId, geonameId: response.clusterGeonameId, rank: response.clusterRank }
            else
              geonameId = null
              QueryString.modify({ in: geonameId })
          .error (response) -> ErrorReporter.silent( response, 'SinglePageLocations findWithGeonameObject Location', geoname_obj: JSON.stringify(geonameObj) )
      QueryString.modify({ in: geonameId })

    setLocationByGeonameId: ( geonameId ) ->
      self = @
      unless self.locations[ geonameId ]?.clusterId || _.include( self.locationsQueried, parseInt(geonameId) )
        self.locationsQueried.push parseInt(geonameId)
        Location.findWithGeonameId( geonameId )
          .success (response) ->
            if response
              self.locations[ parseInt( response.geonameId ) ] = response
              self.clusters[ parseInt( response.clusterId ) ] = { name: response.clusterName, lat: response.clusterLat, lon: response.clusterLon, id: response.clusterId, geonameId: response.clusterGeonameId, rank: response.clusterRank }
            else
              geonameId = null
              QueryString.modify({ in: geonameId })
          .error (response) -> ErrorReporter.silent( response, 'SinglePageLocations findWithGeonameId Location', geoname_id: geonameId )
      QueryString.modify({ in: geonameId })

    fetchGeoname: ( geonameId, callback ) ->
      self = @
      callback?()
      return self.locations[geonameId] if self.locations[geonameId]

    fetchUsersLocations: ( userId ) ->
      self = @
      return unless userId
      return unless self.fetchingUserLocations != userId
      self.fetchingUserLocations = userId
      User.locations( userId )
        .success (responses) -> 
          _.forEach responses, (r) -> 
            self.locations[r.geonameId] = r unless self.locations[r.geonameId]
            self.locations[r.geonameId].users = [] unless self.locations[r.geonameId].users
            self.locations[r.geonameId].users.push userId
          self.usersQueried.push userId
          self.fetchingUserLocations = null
        .error (response) -> 
          self.fetchingUserLocations = null
          ErrorReporter.silent( response, 'SinglePageLocations fetch Users Locations', user_id: userId )

    usersLocations: ( userId ) ->
      self = @ 
      return unless userId
      userLocationsFound = _.filter( self.locations, (l) -> _.include( l.users, userId ) )
      if userLocationsFound.length
        return userLocationsFound
      else if _.include( self.usersQueried, userId )
        return []
      else if self.fetchingUserLocations != userId
        self.fetchUsersLocations( userId )
        return []
      else
        return []

    usersCountries: ( userId ) ->
      self = @ 
      return unless userId
      userCountriesFound = _.filter( self.locations, (l) -> l.fcode == 'PCLI' && _.include( l.users, userId ) )
      if userCountriesFound.length
        return userCountriesFound
      else if _.include( self.usersQueried, userId )
        return []
      else if self.fetchingUserLocations != userId
        self.fetchUsersLocations( userId )
        return []
      else
        return []

    clusterName: ( location ) -> if location && cluster = @.clusters[ parseInt(location.clusterId) ] then cluster.name else if location then location.name

    countryClusters: ( geonameId ) ->
      self = @
      return [] unless geonameId
      return [] if self.fetchingCountryClusters == geonameId
      countryClustersFound = _.filter( self.clusters, (c) -> parseInt( c.countryId ) == parseInt( geonameId ) )
      return countryClustersFound if _.include( self.countriesClustersFetched, parseInt( geonameId ) )
      self.fetchingCountryClusters = geonameId
      Location.countryClusters( geonameId )
        .success (responses) -> 
          index = 0
          _.forEach responses, (r) -> 
            self.clusters[r.id] = r unless self.clusters[r.id]
            self.clusters[r.id].rank = index
            index++
          self.countriesClustersFetched.push geonameId
          self.fetchingCountryClusters = null
        .error (response) -> 
          self.fetchingCountryClusters = null
          ErrorReporter.silent( response, 'SinglePageLocations fetching Country Admins', country_id: geonameId )
      return []

    fetchCountryAdmins: ( countryId ) ->
      self = @
      return unless countryId
      return unless self.fetchingCountryAdmins != countryId
      self.fetchingCountryAdmins = countryId
      Geonames.adminOnes( countryId )
        .success (responses) -> 
          _.forEach responses.geonames, (r) -> 
            self.locations[r.geonameId] = r unless self.locations[r.geonameId]
          self.countriesQueried.push countryId
          self.fetchingCountryAdmins = null
        .error (response) -> 
          self.fetchingCountryAdmins = null
          ErrorReporter.silent( response, 'SinglePageLocations fetching Country Admins', country_id: countryId )

    countryAdmins: ( countryId ) ->
      self = @
      return unless countryId
      if _.include( self.countriesQueried, countryId ) && countryAdminsFound = _.filter( self.locations, (l) -> parseInt( l.countryId ) == parseInt( countryId ) && l.fcode == 'ADM1' )
        return _.sortBy( countryAdminsFound, (c) -> c.name )
      else if _.include( self.countriesQueried, countryId )
        return _.sortBy( _.filter( self.locations, (l) -> l.countryId == countryId && l.fcode == 'ADM1' ), (c) -> c.name )
      else
        self.fetchCountryAdmins( countryId )
        return []

  return SPLocations