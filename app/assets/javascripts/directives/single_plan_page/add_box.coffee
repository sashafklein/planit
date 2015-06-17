angular.module("Directives").directive 'addBox', (Flash, ErrorReporter, Geonames, QueryString, Foursquare, Place, Mark, Item, $timeout, RailsEnv, ClassFromString, $sce) ->
  {
    restrict: 'E'
    replace: true
    templateUrl: 'single/plan_box/_add_box.html'
    scope:
      m: '='
    link: (s, e, a) ->
      
      s.clearAdd = -> s.m.adding = false if !s.placeSearchFocused

      s.nearbySearchResultClass = (option, index=0) -> ClassFromString.toClass( option.name, option.adminName1, option.countryName, index )
      
      s.placeNameOptionClass = (option) -> ClassFromString.toClass(option.name)

      s.placeholderVerb = -> "add" # if ( s.m.plan()?.userOwns() || !s.m.plan() ) then 'add' else 'suggest'
      s.placeholderPhrase = -> if s.m.mobile then "What" else "What do you want to #{s.placeholderVerb()}"
      s.nameSearchPlaceholder = -> 
        in_location = if s.nearbyToReset()?.length>0 then " in #{s.nearbyToReset().split(',')[0]}" else ""
        if !s.m.mobile && location
          "#{s.placeholderPhrase()}#{in_location}?"
        else
          "What#{ in_location }?"

      s.countryLocations = ( locations ) -> 
        return unless locations
        if !s.countryOnlyContext()
          locations
        else
          _.filter( locations, (l) -> parseInt(l.countryId) == parseInt(s.countryOnlyContext()?.geonameId) && l.fcode != "PCLI" )
      s.countryOnlyContext = -> latest = s.m.plan()?.latestLocation(); if latest?.fcode == "PCLI" then latest else null
      s.placeNearbyMessage = -> 
        in_country = "" # " in #{s.m.selectedCountry.name}" if s.m.selectedCountry?.name
        if !s.countryOnlyContext() && !s.m.mobile
          "Where?"
        else if s.m.mobile
          "Where#{in_country}?"
        else
          "Where in #{ s.m.plan()?.latestLocation()?.name }?"

      s.m.addBoxManuallyToggled = false
      s.addBoxToggle = -> 
        s.m.addBoxToggled = !s.m.addBoxToggled
        s.m.addBoxManuallyToggled = true

      s.searchPlaceNearby = -> 
        s.m.nearbyOptions = [] if s.placeNearby?.length || s.m.typing
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

      s.setNearBestOption = ->
        return unless s.m.nearbyOptions?.length
        keepGoing = true
        _.forEach s.m.nearbyOptions, ( option ) ->
          if s.placeNearbyOptionSelectable( option ) && keepGoing
            s.setNearby( option )
            s.m.placeNearby = null
            keepGoing = false

      s.setNearby = ( nearby ) ->
        # s.m.locations[ parseInt( nearby['geonameId'] ) ] = nearby unless s.m.locations[ parseInt( nearby['geonameId'] ) ]
        s.currentNearby = nearby
        s.m.nearbyOptions = []
        s.m.nearbySearchStrings = []
      
      s.addMark = ( option ) -> s.m.placeManager.addMark( option ); s.m.adding=false; s.m.placeName = null
      s.lazyAddMark = -> s.addMark( s.options[0] ) if s.options?.length == 1

      s.placeNameSearch = -> 
        s.m.placeNameOptions = [] if s.m.placeName?.length<1 || s.m.typing
        s._placeSearchFunction() if s.m.placeName?.length > 1

      s._placeSearchFunction = _.debounce( (-> s._makePlaceSearchRequest() ), 500 )

      s.placeNameWorking = 0
      s._makePlaceSearchRequest = ->
        latLng = null
        if s.m.currentLocation()?.lat && s.m.currentLocation()?.lon
          latLng = "#{s.m.currentLocation().lat},#{s.m.currentLocation().lon}"
        else if s.currentNearby?.lat && s.currentNearby?.lon
          latLng = "#{s.currentNearby.lat},#{s.currentNearby.lon}"
        return unless latLng && s.m.placeName?.length>1
        s.placeNameWorking++
        Foursquare.search( latLng , s.m.placeName )
          .success (response) ->
            s.placeNameWorking--
            s.m.placeNameOptions = if !s.m.typing then Place.generateFromJSON Foursquare.parse(response) else []
            _.forEach( s.m.placeNameOptions, (option) -> if placeOnPage = _.find( s.m.places, (p) -> p['foursquare_id'] == option['foursquare_id'] ) then option.id = placeOnPage['id'] )
          .error (response) ->
            s.placeNameWorking--
            if response && response.length > 0 && response.match(/failed_geocode: Couldn't geocode param/)?[0]
              ErrorReporter.silent(response, 'SinglePagePlans s._makePlaceSearchRequest getting geocode rejected', { near: s.m.currentLocation(), query: s.m.placeName }) if response.message != "Insufficient search params"
            else
              ErrorReporter.silent(response, 'SinglePagePlans s._makePlaceSearchRequest', { near: s.m.currentLocation(), query: s.m.placeName }) if response.message != "Insufficient search params"

      s.nearbyToReset = -> 
        location_to_use = if s.m.currentLocation() then s.m.currentLocation() else if s.currentNearby then s.currentNearby 
        return unless location_to_use
        _.compact([ location_to_use.name, location_to_use.adminName1, location_to_use.countryName ]).join(", ")

      s.resetNearby = -> 
        s.m.placeName = null
        s.placeNearby = null
        s.currentNearby = null
        $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
        return

      window.addbox = s
  }