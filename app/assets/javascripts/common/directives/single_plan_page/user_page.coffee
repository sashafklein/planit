angular.module("Common").directive 'userPage', ($http, User) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_user_page.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.loadPlan = (planId) -> s.m.planManager.fetchPlan(planId)

      s.m.workingNow = true
      $http.get('/assets/lib/countries.json')
        .then( (res) -> 
          s.countries = {}
          _.forEach( res.data, (c) -> s.countries[ c['id'] ] = c )
          $http.get('/assets/lib/countries.geojson')
            .then( (res) -> 
              s.geojson = res.data
              _.forEach( s.geojson.features, (f) -> _.extend( f.properties, s.countries[f.id] ) )
              s.m.workingNow = false
            )
        )

      s.m.focusOnCountry = ( geonameId ) -> s.m.selectedLocationId = geonameId

      s.countryLocationsBank = {}
      s.m.selectedCountryLocations = -> 
        return unless s.m.userInQuestionLocations()?.length>0 && s.m.selectedLocationId
        return s.countryLocationsBank[ s.m.selectedLocationId ] if s.countryLocationsBank[ s.m.selectedLocationId ]?.length>0
        s.countryLocationsBank[ s.m.selectedLocationId ] = _.filter( s.m.userInQuestionLocations(), (l) -> l.countryId == s.m.selectedLocationId )
        return s.countryLocationsBank[ s.m.selectedLocationId ]

      s.countriesOn = ( continent ) -> 
        return unless s.countries && Object.keys( s.countries ).length > 0
        _.filter( s.countries, (c) -> c.continent == continent )

      s.userLocationBank = {}
      s.userLocations = (id) ->
        return unless s.m.userInQuestionLoaded
        return s.userLocationBank[id] if s.userLocationBank[id]
        s.userLocationBank[id] = []
        User.locations( id )
          .success (response) ->
            return s.userLocationBank[id] = response
          .error (response) -> console.log "failed to load user locations in time"

      s.m.userInQuestionLocations = -> 
        return null unless s.m.userInQuestion()
        s.userLocations( s.m.userInQuestion().id )

      s.userInQuestionHasCountry = ( geonameId ) -> _.find( s.m.userInQuestionLocations(), (l) -> parseInt( l.countryId ) == parseInt( geonameId ) )

      s.openCountry = ( geonameId ) -> s.openedCountry = _.find( s.m.userInQuestionLocations(), (l) -> parseInt( l.countryId ) == parseInt( geonameId ) )

      s.planImage = ( plan ) -> plan?.best_image?.url?.replace("69x69","210x210")

      window.userscope = s
  }