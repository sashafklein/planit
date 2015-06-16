angular.module("Directives").directive 'locationSearch', (QueryString, Geonames, ErrorReporter, ClassFromString, $timeout, $sce) ->
  {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_location_search.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.locationSearchPrompt = -> 
        if s.m.selectedCountry?.name then "Search cities & regions in #{s.m.selectedCountry.name}" else "Search cities, regions & countries"

      s.blurUserSelect = -> 
        $timeout(-> if $('input#user-select') then $('input#user-select').blur() )
        return

      s.focusOnUserSelect = ->
        s.selectingUser=true
        $timeout(-> if $('input#user-select') then $('input#user-select').focus() )
        return

      s.userNameSelectIncludes = ( string ) -> 
        return null unless string?.length && s.selectedUserName?.length
        return false if string == s.selectedUserName
        toMatch = new RegExp( s.selectedUserName.toLowerCase() )
        if string.toLowerCase().match( toMatch )?.length then return true else return false

      s.chooseFirstUser = ->
        return unless s.userOptions()?.length > 0
        s.selectThisUser( s.userOptions()[0] )

      s.selectThisUser = ( user ) -> 
        QueryString.modify({ u: user.id }) unless user.id == s.m.userInQuestionId
        s.blurUserSelect()

      s.userOptions = -> 
        trustCircle = s.m.userManager.trustCircle( s.m.userInQuestionId )
        return trustCircle unless s.selectedUserName?.length
        toMatch = new RegExp( s.selectedUserName.toLowerCase() )
        _.filter( trustCircle, (u) -> u.name.toLowerCase().match( toMatch )?.length )

      s.planNearbyOptionClass = (option, index=0) -> ClassFromString.toClass( option.name, option.adminName1, option.countryName, index )
      s.searchedPlanClass = (plan, index=0) -> ClassFromString.toClass( plan?.name, index ) unless !plan
      s.nearbyOptions = -> s.m.nearbyOptions unless !s.planNearby?.length

      s.searchedPlans = -> 
        if s.m.hoveredCountry?.name 
          toMatchHover = new RegExp( s.m.hoveredCountry.name.toLowerCase() )
          return _.filter s.m.planManager.plans, (p) -> 
            if _.compact( _.map( p.locations, (l) -> ("#{l.name}  #{l.asciiName?}  #{l.countryName}")?.toLowerCase()?.match( toMatchHover )?.length ) ).length then true else false
        else if s.planNearby?.length>0
          toMatchQuery = new RegExp( s.planNearby.toLowerCase() )
          return _.filter s.m.planManager.plans, (p) -> 
            if p.name?.toLowerCase()?.match( toMatchQuery )?.length
              true
            else if toMatchQuery && _.compact( _.map( p.locations, (l) -> ("#{l.name}  #{l.asciiName?}")?.toLowerCase()?.match( toMatchQuery )?.length ) ).length
              true
            else
              false
        else
          return s.m.planManager.plans

      s.planNearbyBlur = -> $('input#plan-nearby').blur() if $('input#plan-nearby'); s.planNearby=null; s.planNearbyFocused=false; return
      s.exitNearby = -> 
        if s.exitNearbyReady
          s.m.clearLocation(); s.exitNearbyReady=false
        else
          s.exitNearbyReady=true

      s.wherePrompt = ->
        if s.m.userInQuestionId == s.m.currentUserId
          if s.m.selectedCountry?.name
            return "Where are you exploring in #{s.m.selectedCountry.name}?"
          else if s.m.hoveredCountry?.name
            return "Explore #{s.m.hoveredCountry.name}"
          else
            return "Where are you exploring?"
        else
          if s.m.selectedCountry?.name
            return "Where in #{s.m.userInQuestion.name}'s #{s.m.selectedCountry.name}?"
          else if s.m.hoveredCountry?.name
            return "Explore #{s.m.userInQuestion.name}'s #{s.m.hoveredCountry.name}"
          else 
            return "Where in #{s.m.userInQuestion.name}'s Planit?"

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
            ErrorReporter.silent(response, 'SinglePagePlans s.searchPlanNearby', { query: s.planName })

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

      s.selectNearby = ( nearby ) ->
        return unless Object.keys( nearby )?.length>0
        if s.m.countries && s.country = _.find( s.m.countries, (c) -> parseInt(c.geonameId) == parseInt(nearby.countryId) )
          s.m.selectCountry( s.country )
        s.m.setLocation( parseInt(nearby.geonameId) ) unless nearby.fcode == "PCLI"
        s.m.selectedNearby = nearby
        # # scroll to top
        s.planNearby = null
        s.m.nearbyOptions = []
        s.m.browsing = true

      window.start = s

  }