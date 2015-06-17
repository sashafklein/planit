#= require ../../lib/country_json

angular.module("SPA").directive 'userPage', ($http, $timeout, User, CountryJson) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_user_page.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.$watch( 'm.currentPlanId', (-> s.loadCountries() ), true)
      s.loadCountries = ->
        return if s.m.currentPlanId || s.m.countries || s.geojson || s.m.mobile
        s.m.workingNow = true
        s.m.countries = {}
        _.forEach( CountryJson.json, (c) -> s.m.countries[ c['id'] ] = c )
        s.geojson = CountryJson.geojson
        _.forEach( s.geojson.features, (f) -> _.extend( f.properties, s.m.countries[f.id] ) )
        s.m.workingNow = false

      s.m.clearLocation = -> s.clearLocationPopup()
      s.clearLocationPopup = -> s.m.resetUserMapView(); s.m.selectedCountry=null; s.narrowedRegion=null; s.narrowedCounty=null; s.m.selectedNearby=null; s.showNarrowing=false; s.lastBestNearbyIs=null
      s.clearLocationPopupIfOutCountry = -> s.clearLocationPopup() unless s.inCountry

      s.trustCircle = -> s.m.userManager.trustCircle( s.m.userInQuestionId )

      s.trustedUser = ( user ) -> _.include( _.map( s.trustCircle(), (u) -> u.id ), user.id ) if s.trustCircle()

      s.countryClusters = -> s.m.locationManager.countryClusters( s.m.selectedCountry.geonameId ) if s.m.selectedCountry?.geonameId

      s.setCluster = ( cluster ) -> s.m.setLocation( cluster ) # if cluster?.geonameId then s.m.setLocation( parseInt(cluster.geonameId) )

      window.userscope = s
  }