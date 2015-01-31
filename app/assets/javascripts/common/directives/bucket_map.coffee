angular.module("Common").directive 'bucketMap', (MapOptions, F, API, Place, User, PlanitMarker, ClusterLocator, BasicOperators) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "bucket_map.html"
    scope:
      userId: '@'
      currentUserId: '@'
      type: '@'
      zoomControl: '@'
      scrollWheelZoom: '@'
      paddingToUse: '@'
      showList: '@'

    link: (s, element) ->
      window.s = s

      s.showList = true unless s.showList

      User.findPlaces( s.userId )
        .success (places) ->
          s.primaryPlaces = Place.generateFromJSON(places.user_pins)
          s.drawMap(s, element)
        .error (response) ->
          alert("Failed to grab places information!")
          console.log response

      if s.paddingToUse then s.paddingToFocusArea = JSON.parse("[" + s.paddingToUse + "]") else s.paddingToFocusArea = [35, 25, 15, 25]

      s.expanded = -> s.$parent.mapExpanded

      s.$parent.$watch 'mapExpanded', (value) ->
        if s.map?
          currentBounds = s.map.getBounds()
          setTimeout (->
            s.map.invalidateSize()
            s.map.fitBounds(currentBounds, { paddingTopLeft: [s.paddingToFocusArea[3], s.paddingToFocusArea[0]], paddingBottomRight: [s.paddingToFocusArea[1], s.paddingToFocusArea[2]] } )
            return
          ), 400
      
      # Cluster Locator Functions
      s.clusterImage = (location) -> ClusterLocator.imageForLocation(location)
      s.bestListLocation = (places, center) ->
        location = Place.lowestCommonArea(places)
        location ||= ClusterLocator.nearestGlobalRegion(center)
      s.namesOrZoomForMore = (places) -> ClusterLocator.namesOrZoomForMore(places)

      s.generateContextualUserPins = ->
        if s.currentUserId != s.userId
          User.findPlaces( s.currentUserId )
            .success (places) ->
              places = Place.generateFromJSON(places.current_user_pins)
              s.contextPlaces = _(places).select (place) ->
                !_( _(s.primaryPlaces).map('id') ).contains( place.id )
              for contextPlace in s.contextPlaces.value()
                PlanitMarker.contextPin(contextPlace).addTo(s.contextGroup)
            .error (response) ->
              alert("Failed to grab current user's other places!")
              console.log response

      s.drawMap = (s, elem) ->

        scrollWheelZoom = false unless s.scrollWheelZoom
        doubleClickZoom = true
        zoomControl = s.zoomControl || false
        minZoom = 1 if s.type == 'worldview'
        minZoom = 2 if s.type != 'wordlview'
        maxZoom = 18

        id = "main_map"
        elem.attr('id', id)

        s.map = L.map(id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom, maxBounds: [[-84,-400],[84,315]] } )
        
        L.tileLayer('http://otile1.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg',
          attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
        ).addTo(s.map)
          
        # Create context layer and pins
        s.contextGroup = L.layerGroup()
        s.map.addLayer(s.contextGroup)
        s.generateContextualUserPins() if s.currentUserId

        # Primary Pins in Clusters if Plan, WorldView
        clusterMarkers = new L.MarkerClusterGroup({
          maxClusterRadius: 50,
          showCoverageOnHover: true,
          disableClusteringAtZoom: 18,
          spiderfyDistanceMultiplier: 2,
          polygonOptions: { color: '#ff0066', opacity: 1.0, fillColor: '#ff0066', fillOpacity: 0.4, weight: 3 },
          paddingToFocusArea: s.paddingToFocusArea,
        })
        i = 0
        s.primaryCoordinates = []
        while i < s.primaryPlaces.length
          a = s.primaryPlaces[i]
          s.primaryCoordinates.push [a.lat,a.lon]
          clusterMarker = PlanitMarker.primaryPin(a)
          clusterMarkers.addLayer clusterMarker
          i++
        s.map.addLayer(clusterMarkers)

        # Center map and inject zoom control
        s.bounds = new L.LatLngBounds(s.primaryCoordinates)
        s.map.fitBounds(s.bounds, { paddingTopLeft: [s.paddingToFocusArea[3], s.paddingToFocusArea[0]], paddingBottomRight: [s.paddingToFocusArea[1], s.paddingToFocusArea[2]] } )
        new L.Control.Zoom({ position: 'topright' }).addTo(s.map)

        # Control whether or not context pins are viewable
        s.showHideContext = () ->
          if s.map.getZoom() > 11
            s.map.addLayer(s.contextGroup)
          else
            s.map.removeLayer(s.contextGroup)
        s.showHideContext()
        s.map.on "zoomend", -> s.showHideContext()

        # Relay back sidelist marker info
        s._clusterObject = (cluster) ->
          places = _( cluster.getAllChildMarkers() ).map('options').map('placeObject').value()
          center = cluster._latlng
          return { count: cluster._childCount, center: center, places: places, location: s.bestListLocation(places, center) }
        s.currentBounds = -> s.map.getBounds()
        s.changePlacesInView = () ->
          s.placesInView = []
          s.clustersInView = []
          currentBounds = s.currentBounds()
          stuffOnMap = clusterMarkers._featureGroup.getLayers()
          
          for layer in stuffOnMap
            s.placesInView.push( layer.options.placeObject ) if layer.options.placeObject && currentBounds.contains( layer._latlng )
            s.clustersInView.push( s._clusterObject(layer) ) if layer._childCount > 1 && ( layerBounds = layer._bounds ) && ( currentBounds.contains( layerBounds ) )

          s.clustersInView.sort( BasicOperators.dynamicSort('-count') )
          if s.placesInView == [] && s.clustersInView == [] then s.showList = false else s.showList = true

        s.map.on "moveend", -> s.$apply -> s.changePlacesInView()
        s.map.on "zoomend", -> setTimeout ( -> s.$apply -> s.changePlacesInView() ), 400
        s.changePlacesInView()

  }