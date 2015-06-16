#= require ../../lib/country_json

angular.module("SPA").directive 'userPage', ($http, $timeout, User, CountryJson) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_user_page.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.loadPlan = (planId) -> s.m.workingNow = true; s.m.planManager.fetchPlan(planId, s.m.unworking() )

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

      # s.clustersInCountry = ->
      #   return unless s.m.selectedCountry || s.m.hoveredCountry
      #   selected = parseInt( ( s.m.selectedCountry?.geonameId || "" ) )
      #   hovered = parseInt( ( s.m.hoveredCountry?.geonameId || "" ) )
      #   geonames = _.compact( [selected, hovered] )
      #   return s.admin2s if s.lastClustersCertificate == geonames.join("|") || s.lastClustersCertificate == geonames.reverse().join("|")
      #   s.lastClustersCertificate = geonames.join("|")
      #   admin2s = {}
      #   _.forEach s.trustedContentInCountries( geonames ), (p) ->
      #     _.forEach p.locations, (l) ->
      #       if l.fcode=="ADM2"
      #         admin2s[ l.geonameId ] = l unless admin2s[ l.geonameId ]
      #         admin2s[ l.geonameId ].users = [] unless admin2s[ l.geonameId ].users
      #         admin2s[ l.geonameId ].users.push p.user
      #   return s.admin2s = admin2s

      # s.trustedContentInCountries = ( geonames ) ->
      #   return unless geonames
      #   usersWithPlans = _.map(s.trustCircle(),(u)->"#{u.id}#{s.m.planManager.userPlansLoaded[u.id]}").join('|')
      #   trustCertificate = "#{usersWithPlans}:#{geonames.join('|')}"
      #   return s.trustedContentInLocationIs if trustCertificate == s.lastTrustCertificate && s.trustedContentInLocationIs
      #   s.lastTrustCertificate = trustCertificate
      #   s.trustedContentInLocationIs = _.filter s.m.planManager.inCountries( geonames ), (p) -> s.trustedUser( p.user )

      s.locationMatch = ( locations ) -> 
        nearby = s.m.bestNearby()
        return unless nearby
        _.find( locations, (l) -> ( parseInt(nearby.geonameId) == parseInt(l.geonameId) || parseInt(nearby.geonameId) == parseInt(l.adminId1) || parseInt(nearby.geonameId) == parseInt(l.adminId2) || parseInt(nearby.geonameId) == parseInt(l.countryId) ) )

      s.trustedContentInLocation = ->
        SN = s.m.bestNearby()?.geonameId
        usersWithPlans = _.map(s.trustCircle(),(u)->"#{u.id}#{s.m.planManager.userPlansLoaded[u.id]}").join('|')
        trustCertificate = "#{usersWithPlans}:#{SN}"
        return s.trustedContentInLocationIs if trustCertificate == s.lastTrustCertificate && s.trustedContentInLocationIs
        s.lastTrustCertificate = trustCertificate
        if inCountry = s.m.planManager?.inCountries( [s.m.selectedCountry?.geonameId] )
          s.trustedContentInLocationIs = _.sortBy( _.filter( inCountry, (p) -> s.trustedUser( p.user ) && s.locationMatch( p.locations ) ), (p) -> if p.user_id==s.m.userInQuestionId then 0 else 1 )

      s.trustedUsersWithContentInLocation = -> 
        _.map _.uniq( _.compact( _.map( s.trustedContentInLocation(), (c) -> c.user?.id ) ) ), (id) ->
          s.m.userManager.fetch( id )

      s.trustedContentInLocationAndSearch = ->
        content = _.sortBy( s.trustedContentInLocation(), (p) -> p.updated_at ).reverse()
        if s.filteredAdminOnes()?.length > 0
          plansToReturn = _.filter content, (p) -> 
            _.find p.locations, (l) -> 
              _.include( _.map( s.filteredAdminOnes(), (a) -> parseInt( a.geonameId ) ), parseInt( l.adminId1 ) )
        else
          content

      s.countryClusters = -> s.m.locationManager.countryClusters( s.m.selectedCountry.geonameId ) if s.m.selectedCountry?.geonameId

      s.setCluster = ( cluster ) -> if cluster?.geonameId then s.m.setLocation( parseInt(cluster.geonameId) )

      s.planImage = ( plan ) -> plan?.best_image?.url?.replace("69x69","210x210")

      s.m.bestNearby = -> 
        SN = s.m.selectedNearby?.geonameId; SC = s.m.selectedCountry?.geonameId
        bestNearbyCertificate = "#{SN}|#{SC}"
        return s.lastBestNearbyIs if s.lastBestNearbyCertificate == bestNearbyCertificate
        s.lastBestNearbyCertificate = bestNearbyCertificate
        return {} unless s.m.selectedNearby || s.m.selectedCountry
        if s.m.selectedNearby?.name
          s.lastBestNearbyIs = s.m.selectedNearby
        else if s.m.selectedCountry?.name
          s.lastBestNearbyIs = s.m.selectedCountry

      s.startPlanNearby = ->
        nearby = s.m.selectedNearby || s.m.selectedCountry 
        return unless nearby && Object.keys( nearby ).length>0
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