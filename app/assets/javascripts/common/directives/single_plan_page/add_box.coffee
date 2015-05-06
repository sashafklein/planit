angular.module("Common").directive 'addBox', (Flash, ErrorReporter, Geonames, QueryString, Foursquare, Place, Item, $timeout, RailsEnv, ClassFromString) ->
  {
    restrict: 'E'
    replace: true
    templateUrl: 'single/plan_box/_add_box.html'
    scope:
      m: '='
    link: (s, e, a) ->
      
      s.nearbySearchResultClass = (option, index=0) ->
        highlightClass = if s.placeNearbyOptionSelectable(option) then 'highlighted' else null
        highlightClass + ' ' + ClassFromString.toClass( option.name, option.qualifiers, index )
      
      s.placeNameOptionClass = (option, index) -> ClassFromString.toClass(option.name, index)

      s.m.addBoxManuallyToggled = false
      s.addBoxToggle = -> 
        s.m.addBoxToggled = !s.m.addBoxToggled
        s.m.addBoxManuallyToggled = true

      s.searchPlaceNearby = -> 
        s.m.placeNearbyOptions = [] if s.placeNearby?.length
        s._searchPlaceNearbyFunction() if s.placeNearby?.length > 1

      s._searchPlaceNearbyFunction = _.debounce( (-> s._searchPlaceNearby() ), 500 )

      s.placeNearbyWorking = 0
      s._searchPlaceNearby = ->
        return unless s.placeNearby?.length > 1
        s.placeNearbyWorking++
        Geonames.search( s.placeNearby )
          .success (response) ->
            s.placeNearbyWorking--
            s.m.placeNearbyOptions = _.sortBy( response.geonames, 'population' ).reverse()
            _.map( s.m.placeNearbyOptions, (o) -> 
              o.lon = o.lng; o.qualifiers = _.uniq( _.compact( [ o.adminName1 unless o.name == o.adminName1, o.countryName ] ) ).join(", ")
            )
          .error (response) -> 
            s.placeNearbyWorking--
            ErrorReporter.fullSilent(response, 'SinglePagePlaces s.searchPlaceNearby', { query: s.placeName })

      s.placeNearbyOptionSelectable = (option) -> option?.name?.toLowerCase() == s.placeNearby?.split(',')[0]?.toLowerCase()

      s.noPlaceNearbyResults = -> s.placeNearby?.length>1 && s.placeNearbyWorking<1 && s.m.placeNearbyOptions?.length<1

      s.setNearBestOption = ->
        return unless s.m.placeNearbyOptions?.length
        keepGoing = true
        _.forEach s.m.placeNearbyOptions, (o) ->
          if s.placeNearbyOptionSelectable(o) && keepGoing
            s.m.setNearby(o)
            keepGoing = false

      s.addItem = ( option ) -> s.m.plan().addItem( option, s._postAdd( option ), s._postAffix() )
      s.lazyAddItem = -> s.addItem( s.options[0] ) if s.options?.length == 1
      s._postAdd = ( option ) -> s.placeName = null; s.placeNameOptions = null; Flash.success("Adding #{option.names[0]} to your plan"); s.m.addingItem=true
      s._postAffix = -> s.m.addingItem=false

      s.placeNameSearch = -> 
        s.options = [] if s.placeName?.length
        s._placeSearchFunction() if s.placeName?.length > 1 && s.m.nearby?.lat && s.m.nearby?.lon

      s._placeSearchFunction = _.debounce( (-> s._makePlaceSearchRequest() ), 500 )

      s.warnNearby = -> 
        if s.m.nearby?.warned != true
          Flash.warning("'#{s.m.nearby.name}' may be too broad a location to search in") if s.placeName?.length>2 && s.m.nearby?.lat && s.m.nearby?.lon && ( s.m.nearby?.fclName == "parks,area, ..." || s.m.nearby?.fclName == "country, state, region,..." )
          s.m.nearby?.warned = true

      s.noPlaceNameResults = -> if s.placeName?.length>1 && s.placeNameWorking<1 && s.m.placeNameOptions?.length<1 then s.warnNearby() ; return true else return false

      s.placeNameWorking = 0
      s._makePlaceSearchRequest = ->
        return unless s.m.nearby?.lat && s.m.nearby?.lon && s.placeName?.length>0
        s.placeNameWorking++
        Foursquare.search( "#{s.m.nearby.lat},#{s.m.nearby.lon}" , s.placeName)
          .success (response) ->
            s.placeNameWorking--
            s.m.placeNameOptions = Place.generateFromJSON Foursquare.parse(response)
          .error (response) ->
            s.placeNameWorking--
            if response && response.length > 0 && response.match(/failed_geocode: Couldn't geocode param/)?[0]
              Flash.warning("We're having trouble finding '#{s.m.nearby.name}'")
              s.m.nearby = null
            else
              ErrorReporter.fullSilent(response, 'SinglePagePlans s._makePlaceSearchRequest', { near: s.m.nearby, query: s.placeName }) if response.message != "Insufficient search params"

      s.nearbyToReset = -> _.compact([ s.m.nearby?.name, s.m.nearby?.adminName1, s.m.nearby?.countryName ]).join(", ")

      s.resetNearby = -> 
        s.m.nearby = null
        s.placeName = null
        s.placeNearby = null
        s.placeOptions = null
        s.centerNearby = null
        $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
        QueryString.modify({ near: null })
        return

  }