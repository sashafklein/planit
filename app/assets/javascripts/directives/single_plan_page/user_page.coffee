#= require ../../lib/country_json

angular.module("SPA").directive 'userPage', ($http, $timeout, User, CountryJson) ->
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
        return if s.m.currentPlanId || s.m.countries || s.geojson || s.m.mobile
        s.m.workingNow = true
        s.m.countries = {}
        _.forEach( CountryJson.json, (c) -> s.m.countries[ c['id'] ] = c )
        s.geojson = CountryJson.geojson
        _.forEach( s.geojson.features, (f) -> _.extend( f.properties, s.m.countries[f.id] ) )
        s.m.workingNow = false

      s.m.clearLocation = -> s.clearLocationPopup()
      s.clearLocationPopup = -> s.m.resetUserMapView(); s.m.selectedCountry=null; s.m.selectedRegion=null; s.narrowedRegion=null; s.narrowedCounty=null; s.m.selectedNearby=null; s.showNarrowing=false; s.lastBestNearbyIs=null
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

      s.locationsInCountry = -> s.m.locationManager

      s.countryClusters = ->
        clusters = {}
        # _.forEach s.trustedContentInLocationAndSearch(), (plan) -> 
        #   if clusters = _.filter plan.locations, (location) -> location.fcode == "PLANIT"
        #     # represent clusters
        #   else admin2s = 
        #   _.forEach plan.locations, (location) ->
        #     clusters[ location.geonameId ] = location if !clusters[ location.geonameId ] && location.fcode == "ADM2"
        #     # clusters[ location.geonameId ].count = 0 unless clusters[ location.geonameId ].count
        #     # clusters[ location.geonameId ].count = clusters[ location.geonameId ].count + 1
        return clusters
        # return _.sortBy( clusters, "count" ).reverse()

      s.planImage = ( plan ) -> plan?.best_image?.url?.replace("69x69","210x210")

      s.m.bestNearby = -> 
        SN = s.m.selectedNearby?.geonameId; SR = s.m.selectedRegion?.geonameId; SC = s.m.selectedCountry?.geonameId
        bestNearbyCertificate = "#{SN}|#{SR}|#{SC}"
        return s.lastBestNearbyIs if s.lastBestNearbyCertificate == bestNearbyCertificate
        s.lastBestNearbyCertificate = bestNearbyCertificate
        return {} unless s.m.selectedNearby || s.m.selectedRegion || s.m.selectedCountry
        if s.m.selectedNearby?.name
          s.lastBestNearbyIs = s.m.selectedNearby
        else if s.m.selectedRegion?.name
          s.lastBestNearbyIs = s.m.selectedRegion
        else if s.m.selectedCountry?.name
          s.lastBestNearbyIs = s.m.selectedCountry

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