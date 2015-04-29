angular.module("Common").directive 'newGuideStart', (Geonames, ErrorReporter) ->
  {
    restrict: 'E'
    replace: true
    templateUrl: 'single/plan_box/_new_guide_start.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.searchPlanNearby = -> 
        s.planNearbyOptions = [] if s.planNearby?.length
        s._searchPlanNearbyFunction() if s.planNearby?.length > 1

      s._searchPlanNearbyFunction = _.debounce( (-> s._searchPlanNearby() ), 500 )

      s.planNearbyOptionSelectable = (option) -> option?.name?.toLowerCase() == s.planNearby?.split(',')[0]?.toLowerCase()

      s.noPlanNearbyResults = -> s.planNearby?.length>1 && s.planNearbyWorking<1 && s.planNearbyOptions?.length<1

      s.cleanPlanNearbyOptions = -> s.planNearbyOptions = []

      s.planNearbyWorking = 0
      s._searchPlanNearby = ->
        return unless s.planNearby?.length > 1
        s.planNearbyWorking++
        Geonames.search( s.planNearby )
          .success (response) ->
            s.planNearbyWorking--
            s.planNearbyOptions = _.sortBy( response.geonames, 'population' ).reverse()
            _.map( s.planNearbyOptions, (o) -> 
              o.lon = o.lng; o.qualifiers = _.uniq( _.compact( [ o.adminName1 unless o.name == o.adminName1, o.countryName ] ) ).join(", ")
            )
          .error (response) -> 
            s.planNearbyWorking--
            ErrorReporter.fullSilent(response, 'SinglePagePlans s.searchPlanNearby', { query: s.planName })

      s.startListNearBestOption = ->
        return unless s.planNearbyOptions?.length
        keepGoing = true
        _.forEach( s.planNearbyOptions, (o) ->
          if s.planNearbyOptionSelectable(o) && keepGoing
            s.startListNear(o)
            keepGoing = false
        )

      s.startListNear = (option) ->
        return unless option?.name && option?.lat && option?.lon
        s.m.newList( option.name + " Guide" )
        s.m.setNearby( option )

  }