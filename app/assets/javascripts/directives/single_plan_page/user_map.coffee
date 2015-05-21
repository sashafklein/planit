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

    link: (s, elem) ->

      s.center = { lat: 60, lng: 0, zoom: 2 }
      s.userLayers = 
        baselayers: 
          xyz:
            name: 'None'
            url: ""
            type: 'xyz'
            
      geojsonData = {} unless geojsonData

      s.$watch( 'geojsonData', (-> s.geojson() ), true)

      s.loaded = false
      s.screenWidth = if s.m.mobile then 'mobile' else 'web'
      s.padding = [35, 25, 15, 25]

      s.defaults = 
        minZoom: if s.m.mobile then 1 else 2
        maxZoom: 4
        scrollWheelZoom: false
        doubleClickZoom: true
        zoomControl: true
        zoomControlPosition: 'topright'

      s.$on 'leafletDirectiveMap.geojsonMouseover', (ev, feature, leafletEvent) -> s.countryMouseover( feature, leafletEvent ); return
      s.$on 'leafletDirectiveMap.geojsonMouseout', (feature, leafletEvent) -> s.countryMouseleave( feature, leafletEvent ); return
      s.$on 'leafletDirectiveMap.geojsonClick', (ev, featureSelected, leafletEvent) -> s.countryClick( featureSelected, leafletEvent ); return
      s.$on 'leafletDirectiveMap.zoomend', (event) -> 
        if !s.m.plan()?.items?.length
          leafletData.getMap("user").then (m) -> if m._zoom < 4 then s.m.clearSelectedCountry()

      s.m.resetUserMapView = -> leafletData.getMap("user").then (m) -> m.setView( { lat: 35, lng: 0 }, 2 )

      s.m.clearSelectedCountry = ->
        s.m.selectedCountry = null
        s.selectedCountryId = null
        leafletData.getMap("user").then (m) -> _.forEach m._layers, (layer) -> if layer?.feature then layer.setStyle( s.style( layer.feature ) )

      s.countryClick = ( featureSelected, leafletEvent ) -> 
        s.m.clearSelectedCountry()
        leafletData.getMap("user").then (m) -> m.setView( leafletEvent.latlng, 4 )
        s.m.selectedCountry = featureSelected.properties
        s.selectedCountryId = featureSelected.properties.geonameId
        s.m.locationManager.fetchCountryAdmins( s.selectedCountryId )

      s.usersLocationsInCountry = ( countryId ) -> _.filter( s.m.locations, (l) -> parseInt( l.countryId ) == parseInt( countryId ) && _.include( l.users, s.m.userInQuestion().id ) )

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

      s.userCountryCount = -> "#{s.m.currentPlanId}|#{s.m.userInQuestion().id}#|#{s.m.locationManager.usersCountries( s.m.userInQuestion().id )}"

      s.$watch( 'userCountryCount()', (-> s.markCountries() ), true)
      s.markCountries = ->
        return unless s.m.locationManager?.usersCountries( s.m.userInQuestion()?.id )?.length
        leafletData.getMap("user").then (m) -> 
          adjusted = 0          
          _.forEach m._layers, (layer) -> if layer?.feature?.properties then ( layer.setStyle( s.style( layer.feature ) ); adjusted++ ) 
          return unless adjusted == 0
          $timeout( (-> _.forEach m._layers, (layer) -> if layer?.feature?.properties then layer.setStyle( s.style( layer.feature ) )), 2000)

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