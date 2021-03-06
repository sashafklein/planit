angular.module("SPA").directive 'userMap', (leafletData, $timeout, PlanitMarker, QueryString, ErrorReporter, ClassFromString) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'single/user_map.html'
    scope:
      m: '='
      zoomControl: '='
      geojsonData: '='
      locationClusters: '='

    link: (s, elem) ->

      s.invalidateSize = -> leafletData.getMap("user").then (map) -> $timeout(-> map.invalidateSize() )
      s.invalidateSize()
      s.elem = elem
      #   overlays: 
      #     locations:
      #       name: "Location Clusters"
      #       type: "markercluster"
      #       visible: true
      #       layerOptions:
      #         chunkedLoading: true #?look at
      #         showCoverageOnHover: false
      #         removeOutsideVisibleBounds: true
      #         maxClusterRadius: 42
      #         # disableClusteringAtZoom: 13
      #         # spiderifyDistanceMultiplier: 2
      #         iconCreateFunction: (cluster) -> 
      #           initial = 0
      #           s.marker.userMapClusterPin( cluster, initial )

      # s.marker = new PlanitMarker(s)
      # s.buildLocationClusters = ->
      #   s.locationClusterMarkers = {}
      #   _.forEach s.locationClusters, (l) -> 
      #     s.locationClusterMarkers[ l.id ] = s.marker.userMapLocationPin( l )

      # s.$watch( 'locationClusters', (-> s.buildLocationClusters() ), true)
            
      geojsonData = {} unless geojsonData

      s.$watch( 'geojsonData', (-> s.geojson() ), true)

      s.loaded = false
      s.screenWidth = if s.m.mobile then 'mobile' else 'web'
      s.padding = [0, 0, 0, 0]

      s.userDefaults = 
        minZoom: if s.m.mobile then 1 else 2
        maxZoom: 4
        scrollWheelZoom: false
        doubleClickZoom: true
        zoomControl: true
        zoomControlPosition: 'topright'

      s.$on 'leafletDirectiveMap.geojsonMouseover', (ev, feature, leafletEvent) -> s.countryMouseover( feature, leafletEvent ); return
      s.$on 'leafletDirectiveMap.geojsonMouseout', (feature, leafletEvent) -> s.countryMouseleave( feature, leafletEvent ); return
      s.$on 'leafletDirectiveMap.geojsonClick', (ev, featureSelected, leafletEvent) -> s.m.countryClick( featureSelected, leafletEvent ); return
      s.$on 'leafletDirectiveMap.zoomend', (event) -> 
        if !s.m.plan()?.items?.length
          leafletData.getMap("user").then (m) -> if m._zoom < 4 then s.m.clearSelectedCountry()

      s.m.resetUserMapView = -> leafletData.getMap("user").then (map) -> map.setView( { lat: 45, lng: 0 }, 2 ); $timeout(-> map.invalidateSize() )

      s.m.clearSelectedCountry = ->
        s.m.selectedCountry = null
        s.selectedCountryId = null
        leafletData.getMap("user").then (m) -> _.forEach m._layers, (layer) -> if layer?.feature then layer.setStyle( s.style( layer.feature ) )

      s.m.countryClick = ( featureSelected, leafletEvent ) -> 
        s.m.clearSelectedCountry()
        leafletData.getMap("user").then (m) -> m.setView( leafletEvent.latlng, 4 )
        s.m.selectedCountry = featureSelected.properties
        s.selectedCountryId = featureSelected.properties.geonameId
        s.m.locationManager.fetchCountryAdmins( s.selectedCountryId )

      s.m.selectCountry = ( country ) ->
        return unless country && Object.keys( country )?.length>0
        s.m.clearSelectedCountry()
        leafletData.getMap("user").then (m) -> m.setView( { lat: country.lat, lng: country.lng }, 4 ) if country.lat && country.lon
        s.m.selectedCountry = country
        s.selectedCountryId = country.geonameId
        s.m.locationManager.fetchCountryAdmins( s.selectedCountryId )        

      s.usersLocationsInCountry = ( countryId ) -> _.filter( s.m.locations, (l) -> parseInt( l.countryId ) == parseInt( countryId ) && _.include( l.users, s.m.userInQuestionId ) )

      s.getColor = ( feature ) -> 
        if feature?.properties?.geonameId == s.selectedCountryId 
          return "#007"
        else if density = s.usersLocationsInCountry( feature?.properties?.geonameId )?.length
          if density>50 then return "#f06"
          if density>25 then return "#ff3b89"
          if density>10 then return "#ff62a1"
          if density>0 then return "#ff89b8"
        else
          # return "#dacdde"
          return "#ccc"

      s.style = ( feature ) ->
        {
          fillColor: s.getColor( feature ),
          dashArray: '3',
          weight: 2,
          opacity: 1,
          color: 'white',
          fillOpacity: 1
        }

      s.countryMouseover = (feature, leafletEvent) ->
        layer = leafletEvent.target
        s.m.mouseoverLayer = layer
        layer.setStyle
          weight: 2
          color: 'white'
          dashArray: '3'
          fillColor: '#007'
          fillOpacity: 1
        layer.bringToFront()
        s.m.hoveredCountry = feature.properties
        return

      s.countryMouseleave = (feature, leafletEvent) ->
        leafletEvent.target.setStyle s.style( leafletEvent.target.feature )
        s.m.hoveredCountry = null
        return

      s.userCountryCount = -> "#{s.m.currentPlanId}|#{s.m.userInQuestionId}|#{_.map(s.m.locationManager.usersCountries( s.m.userInQuestionId ),(c)->c.geonameId).join('|')}"

      s.$watch( 'userCountryCount()', (-> s.markCountries() ), true)
      s.markCountries = ->
        return unless s.m.locationManager?.usersCountries( s.m.userInQuestionId )?.length
        leafletData.getMap("user").then (m) -> 
          adjusted = 0          
          _.forEach m._layers, (layer) -> if layer?.feature?.properties then ( layer.setStyle( s.style( layer.feature ) ); adjusted++ ) 
          return unless adjusted == 0
          $timeout( (-> _.forEach m._layers, (layer) -> if layer?.feature?.properties then layer.setStyle( s.style( layer.feature ) )), 5000)

      s.geojson = ->
        return if s.geoJsonDataToMap || !s.geojsonData
        s.geoJsonDataToMap = 
          data: s.geojsonData,
          style: 
            fillColor: '#ccc'
            dashArray: '3',
            weight: 2,
            opacity: 1,
            color: 'white',
            fillOpacity: 1

      window.usermap = s
  }