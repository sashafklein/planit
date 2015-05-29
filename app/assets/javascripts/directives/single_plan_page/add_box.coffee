angular.module("Directives").directive 'addBox', (Flash, ErrorReporter, Geonames, QueryString, Foursquare, Place, Item, $timeout, RailsEnv, ClassFromString, $sce) ->
  {
    restrict: 'E'
    replace: true
    templateUrl: 'single/plan_box/_add_box.html'
    scope:
      m: '='
    link: (s, e, a) ->
      
      s.nearbySearchResultClass = (option, index=0) -> ClassFromString.toClass( option.name, option.adminName1, option.countryName, index )
      
      s.placeNameOptionClass = (option) -> ClassFromString.toClass(option.name)

      s.placeholderVerb = -> if s.m.plan()?.userOwns() then 'add' else 'suggest'
      s.placeholderPhrase = -> if s.m.mobile then "What" else "What do you want to #{s.placeholderVerb()}"
      s.placeholder = -> "#{s.placeholderPhrase()} in #{s.m.plan()?.currentLocation()?.name}?"

      s.countryLocations = ( locations ) -> 
        return unless locations
        if !s.countryOnlyContext()
          locations
        else
          _.filter( locations, (l) -> parseInt(l.countryId) == parseInt(s.countryOnlyContext()?.geonameId) && l.fcode != "PCLI" )
      s.countryOnlyContext = -> latest = s.m.plan()?.latestLocation(); if latest?.fcode == "PCLI" then latest else null
      s.placeNearbyMessage = -> 
        if !s.countryOnlyContext()
          "Explore what city or region?"
        else
          "Explore what city or region in #{ s.m.plan()?.latestLocation()?.name }?"

      s.m.addBoxManuallyToggled = false
      s.addBoxToggle = -> 
        s.m.addBoxToggled = !s.m.addBoxToggled
        s.m.addBoxManuallyToggled = true

      s.searchPlaceNearby = -> 
        s.m.nearbyOptions = [] if s.placeNearby?.length
        s._searchPlaceNearbyFunction() if s.placeNearby?.length > 1

      s._searchPlaceNearbyFunction = _.debounce( (-> s._searchPlaceNearby() ), 500 )

      s.placeNearbyWorking = 0
      s._searchPlaceNearby = ->
        return unless s.placeNearby?.length > 1
        s.placeNearbyWorking++
        Geonames.search( s.placeNearby )
          .success (response) ->
            s.placeNearbyWorking--
            nearbyOptions = response.geonames
            _.forEach( nearbyOptions, (o) -> o.lon = o.lng; o.isCountry = if parseInt( s.countryOnlyContext()?.geonameId ) == parseInt( o.countryId ) then 0 else 1 )
            s.m.nearbyOptions = _.sortBy( nearbyOptions, 'isCountry' )
            s.m.nearbySearchStrings.unshift s.placeNearby
          .error (response) -> 
            s.placeNearbyWorking--
            ErrorReporter.silent(response, 'SinglePagePlaces s.searchPlaceNearby', { query: s.m.placeName })

      s.underlined = ( text_array ) ->
        location_text = _.compact( text_array ).join(", ")
        terms = s.placeNearby?.split(/[,]?\s+/)
        _.forEach( terms, (t) ->
          regEx = new RegExp( "(#{t})" , "ig" )
          location_text = location_text.replace( regEx, "<u>$1</u>" )
        )
        $sce.trustAsHtml( location_text )

      s.placeNearbyOptionSelectable = (option) -> option?.name?.toLowerCase() == s.placeNearby?.split(',')[0]?.toLowerCase()

      s.noPlaceNearbyResults = -> s.placeNearby?.length>1 && s.placeNearbyWorking<1 && s.m.nearbyOptions?.length<1

      s.setNearBestOption = ->
        return unless s.m.nearbyOptions?.length
        keepGoing = true
        _.forEach s.m.nearbyOptions, ( option ) ->
          if s.placeNearbyOptionSelectable( option ) && keepGoing
            s.setNearby( option )
            s.m.placeNearby = null
            keepGoing = false

      s.setNearby = ( nearby ) ->
        searchStrings = _.compact( s.m.nearbySearchStrings )
        s.m.plan().setNearby( nearby, searchStrings )
        s.m.nearbyOptions = []
        s.m.nearbySearchStrings = []
      
      s.setCurrentNearby = ( nearby ) -> s.m.plan().latest_location_id = nearby.id

      s.addItem = ( option ) -> s.m.plan().addItem( option, s._postAdd( option ), s._postAffix() )
      s.lazyAddItem = -> s.addItem( s.options[0] ) if s.options?.length == 1
      s._postAdd = ( option ) -> s.m.addingItem=true; s.m.placeName = null; s.placeNameOptions = null; Flash.success("Adding #{option.names[0]} to your plan")
      s._postAffix = -> s.m.addingItem=false

      s.placeNameSearch = -> 
        s.options = [] if s.m.placeName?.length
        s._placeSearchFunction() if s.m.placeName?.length > 1 && s.m.plan()?.currentLocation()?.lat && s.m.plan()?.currentLocation()?.lon

      s._placeSearchFunction = _.debounce( (-> s._makePlaceSearchRequest() ), 500 )

      s.noPlaceNameResults = -> if s.m.placeName?.length>1 && s.placeNameWorking<1 && s.m.placeNameOptions?.length<1 then return true else return false

      s.placeNameWorking = 0
      s._makePlaceSearchRequest = ->
        return unless s.m.plan()?.currentLocation()?.lat && s.m.plan()?.currentLocation()?.lon && s.m.placeName?.length>0
        s.placeNameWorking++
        Foursquare.search( "#{s.m.plan()?.currentLocation().lat},#{s.m.plan()?.currentLocation().lon}" , s.m.placeName)
          .success (response) ->
            s.placeNameWorking--
            s.m.placeNameOptions = Place.generateFromJSON Foursquare.parse(response)
          .error (response) ->
            s.placeNameWorking--
            if response && response.length > 0 && response.match(/failed_geocode: Couldn't geocode param/)?[0]
              ErrorReporter.silent(response, 'SinglePagePlans s._makePlaceSearchRequest getting geocode rejected', { near: s.m.plan()?.currentLocation(), query: s.m.placeName }) if response.message != "Insufficient search params"
            else
              ErrorReporter.silent(response, 'SinglePagePlans s._makePlaceSearchRequest', { near: s.m.plan()?.currentLocation(), query: s.m.placeName }) if response.message != "Insufficient search params"

      s.nearbyToReset = -> _.compact([ s.m.plan()?.currentLocation()?.name, s.m.plan()?.currentLocation()?.adminName1, s.m.plan()?.currentLocation()?.countryName ]).join(", ")

      s.resetNearby = -> 
        s.m.plan().userResetNear = true
        s.m.plan().latest_location_id = null
        s.m.placeName = null
        s.placeNearby = null
        s.placeOptions = null
        s.centerNearby = null
        $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
        QueryString.modify({ near: null })
        return

      window.addbox = s
  }