angular.module("Common").directive 'userPage', ($http, $timeout, User) ->
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
          s.m.countries = {}
          _.forEach( res.data, (c) -> s.m.countries[ c['id'] ] = c )
          $http.get('/assets/lib/countries.geojson')
            .then( (res) -> 
              s.geojson = res.data
              _.forEach( s.geojson.features, (f) -> _.extend( f.properties, s.m.countries[f.id] ) )
              s.m.workingNow = false
            )
        )

      s.clearLocationPopup = -> s.m.resetUserMapView(); s.m.selectedCountry=null; s.m.selectedRegion=null; s.narrowedRegion=null; s.narrowedCounty=null; s.m.selectedNearby=null
      s.clearLocationPopupIfOutCountry = -> s.clearLocationPopup() unless s.inCountry

      s.m.focusOnCountry = ( geonameId ) -> s.m.selectedLocationId = geonameId

      s.countryLocationsBank = {}
      s.m.selectedCountryLocations = -> 
        return unless s.m.userInQuestionLocations()?.length>0 && s.m.selectedLocationId
        return s.countryLocationsBank[ s.m.selectedLocationId ] if s.countryLocationsBank[ s.m.selectedLocationId ]?.length>0
        s.countryLocationsBank[ s.m.selectedLocationId ] = _.filter( s.m.userInQuestionLocations(), (l) -> l.countryId == s.m.selectedLocationId )
        return s.countryLocationsBank[ s.m.selectedLocationId ]

      s.countriesOn = ( continent ) -> 
        return unless s.m.countries && Object.keys( s.m.countries ).length > 0
        _.filter( s.m.countries, (c) -> c.continent == continent )

      s.narrowRegionMessage = -> if s.setNarrowRegionMessageNull then null else "Narrow by Region (#{ s.plansCount } plans)" 
      s.focusOnNarrowRegion = -> $('input#narrowedRegion').focus() if $('input#narrowedRegion'); return
      s.selectRegion = (region) -> s.m.selectedRegion = region if region; setNarrowRegionMessageNull=false
      s.adminOnes = ( country_id ) -> _.filter( s.m.userInQuestionLocations(), (l) -> l.countryId == country_id && l.fcode == 'ADM1' )
      s.filteredAdminOnes = ->
        return unless s.m.selectedCountry?.geonameId
        allAdminOnes = s.adminOnes( s.m.selectedCountry.geonameId )
        return allAdminOnes if !s.narrowedRegion
        regex = new RegExp( s.narrowedRegion.toLowerCase() )
        _.filter( allAdminOnes, (a) -> a.name.toLowerCase().match(regex) )
      s.filterByLocation = ( plans ) ->
        if s.m.selectedRegion
          plansToReturn = _.filter( plans, (p) -> _.find( p.locations, (l) -> parseInt( l.adminId1 ) == parseInt( s.m.selectedRegion.geonameId ) ) )
          s.plansCount = plansToReturn.length
          return plansToReturn
        else if s.filteredAdminOnes()?.length
          plansToReturn = _.filter( plans, (p) -> _.find( p.locations, (l) -> _.include( _.map( s.filteredAdminOnes(), (a) -> parseInt( a.geonameId ) ) , parseInt( l.adminId1 ) ) ) )
          s.plansCount = plansToReturn.length
          return plansToReturn

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
        locations = s.userLocations( s.m.userInQuestion().id )
        countries = _.filter( locations, (l) -> l.fcode=="PCLI" )
        return locations if locations.ownershipAsserted || !s.geojson?.features
        _.forEach s.geojson.features, (f) -> 
          if _.include( _.map( countries, (c) -> parseInt( c.geonameId ) ), parseInt( f.properties.geonameId ) )
            f.properties.hasContent=true; return true
          else
            f.properties.hasContent=false; return true
        s.userLocationBank[ s.m.userInQuestion().id ].ownershipAsserted = true
        $timeout( -> s.m.locationContentFor = s.m.userInQuestion().id )
        return locations

      s.userInQuestionHasCountry = ( geonameId ) -> _.find( s.m.userInQuestionLocations(), (l) -> parseInt( l.countryId ) == parseInt( geonameId ) )

      s.openCountry = ( geonameId ) -> s.openedCountry = _.find( s.m.userInQuestionLocations(), (l) -> parseInt( l.countryId ) == parseInt( geonameId ) )

      s.planImage = ( plan ) -> plan?.best_image?.url?.replace("69x69","210x210")

      s.m.bestNearby = -> 
        return {} unless s.m.selectedNearby || s.m.selectedRegion || s.m.selectedCountry
        if s.m.selectedNearby?.name
          s.m.selectedNearby
        else if s.m.selectedRegion?.name
          s.m.selectedRegion
        else if s.m.selectedCountry?.name
          s.m.selectedCountry

      s.startPlanNearby = ->
        nearby = s.m.selectedNearby ||  s.m.selectedRegion || s.m.selectedCountry 
        debugger
        return unless Object.keys( nearby ).length>0
        searchStrings = _.compact( s.m.nearbySearchStrings )
        s.m.planManager.addNewPlan( nearby, searchStrings )
        s.m.nearbySearchStrings = []

      window.userscope = s
  }