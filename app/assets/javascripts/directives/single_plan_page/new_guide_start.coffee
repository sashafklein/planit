angular.module("Directives").directive 'newGuideStart', (Geonames, ErrorReporter, ClassFromString, $sce) ->
  {
    restrict: 'E'
    replace: true
    templateUrl: 'single/plan_box/_new_guide_start.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.selectedUserName = s.m.userInQuestion().name
      s.calculateSelectedUser = -> s.selectedUserName = s.m.userInQuestion().name
      s.blurOnUserSelect = -> $('input#user-select').blur(); return
      s.focusOnUserSelect = -> $('input#user-select').focus(); return

      s.userNameSelectIncludes = ( string ) -> 
        return null unless string?.length && s.selectedUserName?.length
        return false if string == s.selectedUserName
        toMatch = new RegExp( s.selectedUserName.toLowerCase() )
        if string.toLowerCase().match( toMatch )?.length then return true else return false

      s.chooseFirstUser = ->
        return unless s.userOptions()?.length > 0
        s.selectThisUser( s.userOptions()[0] )

      s.selectThisUser = ( user ) -> null # REVISIT

      s.x = []
      s.m.currentUserUniverse = -> s.x
      
      s.userOptions = -> 
        return s.m.currentUserUniverse() if s.m.currentUserName == s.selectedUserName
        toMatch = new RegExp( s.selectedUserName.toLowerCase() )
        _.filter( s.m.currentUserUniverse(), (u) -> u.name.toLowerCase().match( toMatch )?.length )

      s.planNearbyOptionClass = (option, index=0) -> ClassFromString.toClass( option.name, option.adminName1, option.countryName, index )

      s.wherePrompt = ->
        if s.m.userInQuestion().id == s.m.currentUserId
          "Where are you exploring?"
        else
          "Where in #{s.m.userInQuestion.name}'s Planit?"

      s.searchPlanNearby = -> 
        s.m.nearbyOptions = [] if s.planNearby?.length
        s._searchPlanNearbyFunction() if s.planNearby?.length > 1

      s._searchPlanNearbyFunction = _.debounce( (-> s._searchPlanNearby() ), 500 )

      s.planNearbyOptionSelectable = (option) -> option?.name?.toLowerCase() == s.planNearby?.split(',')[0]?.toLowerCase()

      s.noPlanNearbyResults = -> s.planNearby?.length>1 && s.planNearbyWorking<1 && s.m.nearbyOptions?.length<1

      s.planNearbyWorking = 0
      s._searchPlanNearby = ->
        return unless s.planNearby?.length > 1
        s.planNearbyWorking++
        Geonames.search( s.planNearby )
          .success (response) ->
            s.planNearbyWorking--
            nearbyOptions = response.geonames
            _.map( nearbyOptions, (o) -> o.lon = o.lng )
            s.m.nearbyOptions = nearbyOptions #_.sortBy( nearbyOptions, 'bestScore' ).reverse()
            s.m.nearbySearchStrings.unshift s.placeNearby
          .error (response) -> 
            s.planNearbyWorking--
            ErrorReporter.fullSilent(response, 'SinglePagePlans s.searchPlanNearby', { query: s.planName })

      s.underlined = ( location_text ) ->
        terms = s.planNearby?.split(/[,]?\s+/)
        _.forEach( terms, (t) ->
          regEx = new RegExp( "(#{t})" , "ig" )
          location_text = location_text.replace( regEx, "<u>$1</u>" )
        )
        $sce.trustAsHtml( location_text )

      s.selectNearbyBestOption = ->
        return unless s.m.nearbyOptions?.length
        keepGoing = true
        _.forEach( s.m.nearbyOptions, ( option ) ->
          if s.planNearbyOptionSelectable( option ) && keepGoing
            s.selectNearby( option )
            keepGoing = false
        )

      s.getNewRegion = ( geonameId ) ->
        Geonames.find( geonameId )
          .success (response) -> s.m.selectedRegion = response

      s.selectNearby = ( nearby ) ->
        return unless Object.keys( nearby )?.length>0
        s.m.selectedCountry = _.find( s.m.countries, (c) -> c.geonameId == nearby.countryId ) if s.m.countries
        if nearby.fcode == 'ADM1' then s.m.selectedRegion = nearby else s.getNewRegion( nearby.adminId1 )
        s.m.selectedNearby = nearby
        # # scroll to top
        s.planNearby = null
        s.m.nearbyOptions = []
        s.m.browsing = true

      window.start = s

  }