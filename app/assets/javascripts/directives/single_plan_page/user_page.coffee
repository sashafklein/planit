angular.module("SPA").directive 'userPage', ($http, $timeout, User) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_user_page.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.loadPlan = (planId) -> s.m.workingNow = true; s.m.planManager.fetchPlan(planId, s.unworking() )
      s.unworking = -> s.m.workingNow = false

      s.$watch( 'm.currentPlanId', (-> s.loadCountries() ), true)
      s.loadCountries = ->
        return if s.m.currentPlanId || s.m.countries || s.geojson
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

      s.clearLocationPopup = -> s.m.resetUserMapView(); s.m.selectedCountry=null; s.m.selectedRegion=null; s.narrowedRegion=null; s.narrowedCounty=null; s.m.selectedNearby=null; s.showNarrowing=false
      s.clearLocationPopupIfOutCountry = -> s.clearLocationPopup() unless s.inCountry

      s.narrowRegionMessage = -> if s.showNarrowing then null else if s.narrowedRegion then s.narrowedRegion else if s.allAdminOnes()?.length then "Narrow by Region" else "Loading Regions"
      s.focusOnNarrowRegion = -> 
        return unless s.allAdminOnes()?.length
        s.showNarrowing = true
        $timeout(-> $('input#narrowedRegion').focus() if $('input#narrowedRegion') )
        return
      s.blurNarrowRegion = (override) -> 
        return unless (!s.narrowRegionResultsFocused || override) && s.showNarrowing
        s.showNarrowing=false
        $timeout(-> $('input#narrowedRegion').blur() if $('input#narrowedRegion') )
        return
      
      s.selectRegion = (region) -> s.m.selectedRegion = region if region; showNarrowing=false

      s.allAdminOnes = -> s.m.locationManager.countryAdmins( s.m.selectedCountry.geonameId ) if s.m.selectedCountry?.geonameId
      s.filteredAdminOnes = ->
        return [s.m.selectedRegion] if s.m.selectedRegion
        return unless s.m.selectedCountry?.geonameId 
        return s.allAdminOnes() unless s.narrowedRegion
        regex = new RegExp( s.narrowedRegion.toLowerCase() )
        _.filter( s.allAdminOnes(), (a) -> a.name.toLowerCase().match(regex) )

      s.filterByLocation = ( plans ) ->
        plans = _.sortBy( plans, (p) -> p.updated_at ).reverse()
        if s.filteredAdminOnes()?.length > 0
          plansToReturn = _.filter plans, (p) -> 
            _.find p.locations, (l) -> 
              _.include( _.map( s.filteredAdminOnes(), (a) -> parseInt( a.geonameId ) ), parseInt( l.adminId1 ) )
        else
          plans

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
        return unless Object.keys( nearby ).length>0
        searchStrings = _.compact( s.m.nearbySearchStrings )
        s.m.planManager.addNewPlan( nearby, searchStrings )
        s.m.nearbySearchStrings = []

      # mobile
      # s.m.focusOnCountry = ( geonameId ) -> s.m.selectedLocationId = geonameId
      # s.countriesOn = ( continent ) -> 
      #   return unless s.m.countries && Object.keys( s.m.countries ).length > 0
      #   _.filter( s.m.countries, (c) -> c.continent == continent )

      window.userscope = s
  }