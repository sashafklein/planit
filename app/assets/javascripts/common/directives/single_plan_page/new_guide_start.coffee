angular.module("Common").directive 'newGuideStart', (Geonames, ErrorReporter) ->
  {
    restrict: 'E'
    replace: true
    templateUrl: 'single/plan_box/_new_guide_start.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.planNearbyOptionClass = (option, index=null) ->
        highlightClass = if s.planNearbyOptionSelectable(option) then 'highlighted' else null
        fullName = ( [option.name, String(option.qualifiers)].join(" ") ).replace(',', '').split(" ")
        nameClass = _.compact( [_.map(fullName , (o) -> o.toLowerCase() ).join("-"), String(index)] ).join("-")
        _.compact([highlightClass, nameClass]).join(" ")

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
            s.planNearbyOptions = _.sortBy( response.geonames, 'population' ).reverse()
            _.map( s.planNearbyOptions, (o) -> 
              o.lon = o.lng; o.qualifiers = _.uniq( _.compact( [ o.adminName1 unless o.name == o.adminName1, o.countryName ] ) ).join(", ")
            )
          .error (response) -> 
            s.planNearbyWorking--
            ErrorReporter.fullSilent(response, 'SinglePagePlans s.searchPlanNearby', { query: s.planName })

      s.startPlanNearBestOption = ->
        return unless s.planNearbyOptions?.length
        keepGoing = true
        _.forEach( s.planNearbyOptions, (o) ->
          if s.planNearbyOptionSelectable(o) && keepGoing
            s.startPlanNear(o)
            keepGoing = false
        )

      s.startPlanNear = ( option ) ->
        return unless option?.name && option?.lat && option?.lon
        s.m.planManager.addNewPlan( option )
        s.m.setNearby( option )
        s.planNearby = null

  }