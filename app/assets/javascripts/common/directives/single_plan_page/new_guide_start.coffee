angular.module("Common").directive 'newGuideStart', (Geonames, ErrorReporter, ClassFromString, $sce) ->
  {
    restrict: 'E'
    replace: true
    templateUrl: 'single/plan_box/_new_guide_start.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.planNearbyOptionClass = (option, index) ->
        highlightClass = if s.planNearbyOptionSelectable(option) then 'highlighted' else null
        highlightClass + ' ' + ClassFromString.toClass( option.name, option.qualifiers, index )

      s.searchPlanNearby = -> 
        s.planNearbyOptions = [] if s.planNearby?.length
        s._searchPlanNearbyFunction() if s.planNearby?.length > 1

      s._searchPlanNearbyFunction = _.debounce( (-> s._searchPlanNearby() ), 500 )

      s.planNearbyOptionSelectable = (option) -> option?.name?.toLowerCase() == s.planNearby?.split(',')[0]?.toLowerCase()

      s.noPlanNearbyResults = -> s.planNearby?.length>1 && s.planNearbyWorking<1 && s.planNearbyOptions?.length<1

      s.planNearbyWorking = 0
      s._searchPlanNearby = ->
        return unless s.planNearby?.length > 1
        s.planNearbyWorking++
        Geonames.search( s.planNearby )
          .success (response) ->
            s.planNearbyWorking--
            s.planNearbyOptions = response.geonames #_.sortBy( response.geonames, 'population' ).reverse()
            _.map( s.planNearbyOptions, (o) -> 
              o.lon = o.lng; o.qualifiers = _.uniq( _.compact( [ o.adminName1, o.countryName ] ) ).join(", ")
            )
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

      s.startPlanNearBestOption = ->
        return unless s.planNearbyOptions?.length
        keepGoing = true
        _.forEach( s.planNearbyOptions, ( option ) ->
          if s.planNearbyOptionSelectable( option ) && keepGoing
            s.startPlanNear( option )
            keepGoing = false
        )

      s.startPlanNear = ( nearby ) ->
        return unless nearby?.name && nearby?.lat && nearby?.lon
        searchStrings = _.compact( s.m.nearbySearchStrings )
        s.m.planManager.addNewPlan( nearby, searchStrings )
        s.m.nearbySearchStrings = []
        s.planNearby = null

  }