angular.module("SPA").service "SPLocations", (User, Plan, Location, Geonames, QueryString, ErrorReporter) ->
  class SPLocations

    constructor: ( userId ) ->
      self = @
      self.locations = {}
      self.usersQueried = []
      self.countriesQueried = []
      self.locationsQueried = []
      @fetchUsersLocations( userId )

    fetchGeoname: ( geonameId ) ->
      self = @
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
          ErrorReporter.fullSilent( response, 'SinglePageLocations fetch Users Locations', user_id: userId )

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
          ErrorReporter.fullSilent( response, 'SinglePageLocations fetching Country Admins', country_id: countryId )

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