angular.module("Common").directive 'planMap', (F, Place, Plan, User, PlanitMarker, QueryString) ->

  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: "<div class='ng-map-div'><div ng_transclude=true></div></div>"
    scope:
      planId: '@'
      placeIds: '@'
      currentUserId: '@'
      type: '@'
      zoomControl: '@'
      scrollWheelZoom: '@'
      webPadding: '@'
      mobilePadding: '@'

    link: (s, element) ->

      window.s = s
      s.padding = [35, 25, 15, 25] # default
      s.mobile = if element.width() < 768 then true else false
      s.requireDoubleClick = if s.mobile then true else false
      if s.mobilePadding && s.mobile
        s.padding = JSON.parse("[" + s.mobilePadding + "]")
      else if s.webPadding && !s.mobile
        s.padding = JSON.parse("[" + s.webPadding + "]")

      # Get primaryPlaces from placeID string or planID, trigger draw map
      if s.placeIds
        s.placeIds = JSON.parse(s.placeIds)
        Place.where({ id: s.placeIds })
          .success (places) ->
            s.primaryPlaces = Place.generateFromJSON(places)
            s.drawMap(s, element)
          .error (response) ->
            console.log("Failed to grab places information!")
            console.log response
      else if s.planId
        Plan.findPlaces( s.planId )
          .success (places) ->
            s.primaryPlaces = Place.generateFromJSON(places)
            s.drawMap(s, element)
          .error (response) ->
            alert("Failed to grab plan information!")
            console.log response

      s.expanded = -> s.$parent.mapExpanded
      s.$parent.$watch 'mapExpanded', (value) ->
        if s.map?
          currentBounds = s.map.getBounds()
          setTimeout (->
            s.map.invalidateSize()
            s.map.fitBounds(currentBounds, { paddingTopLeft: [s.padding[3], s.padding[0]], paddingBottomRight: [s.padding[1], s.padding[2]] } )
            return
          ), 400

      s.generateContextualUserPins = ->
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

        # Set map attributes & build map
        s.type = 'default' unless s.type = 'plan'
        scrollWheelZoom = false unless s.scrollWheelZoom
        doubleClickZoom = true
        zoomControl = s.zoomControl || false
        minZoom = 2
        maxZoom = 18
        id = "main_map"
        elem.attr('id', id)
        s.map = L.map(id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom, maxBounds: [[-86,-315],[86,315]] } )
        
        # Tiles
        L.tileLayer('http://otile1.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg', attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>").addTo(s.map)
          
        # Create context layer and pins
        s.contextGroup = L.layerGroup()
        s.map.addLayer(s.contextGroup)
        s.generateContextualUserPins() if s.currentUserId

        s.primaryCoordinates = []

        # Primary Pins in Clusters if Plan, WorldView
        clusterMarkers = new L.MarkerClusterGroup({
          maxClusterRadius: 50,
          requireDoubleClick: s.requireDoubleClick,
          showCoverageOnHover: true,
          disableClusteringAtZoom: 15,
          spiderfyDistanceMultiplier: 2,
          polygonOptions: { color: '#ff0066', opacity: 1.0, fillColor: '#ff0066', fillOpacity: 0.4, weight: 3 },
          padding: s.padding,
          iconCreateFunction: (cluster) -> PlanitMarker.clusterPin( cluster ),
        })
        i = 0
        while i < s.primaryPlaces.length
          place = s.primaryPlaces[i]
          place.leafletLocation = new L.LatLng( place.lat, place.lon )
          s.primaryCoordinates.push [place.lat,place.lon]
          clusterMarker = PlanitMarker.primaryPin(place, true)
          clusterMarkers.addLayer clusterMarker
          i++
        s.map.addLayer(clusterMarkers)

        # Start map (either center or with QueryString) and inject zoom control
        queryCenter = QueryString.centerIs()
        if queryCenter
          s.map.setView( [ parseFloat( queryCenter.lat ), parseFloat( queryCenter.lon ) ], parseInt( queryCenter.zoom ) )
        else
          s.bounds = new L.LatLngBounds(s.primaryCoordinates)
          s.map.fitBounds(s.bounds, { paddingTopLeft: [s.padding[3], s.padding[0]], paddingBottomRight: [s.padding[1], s.padding[2]] } )
        new L.Control.Zoom({ position: 'topright' }).addTo(s.map)

        # Control whether or not context pins are viewable
        s.showHideContext = () ->
          if s.map.getZoom() > 11
            s.map.addLayer(s.contextGroup)
          else
            s.map.removeLayer(s.contextGroup)
        s.showHideContext()

        # On Zoom and Move End
        s.updateQuery = ->
          QueryString.modifyParamValues( m:"#{s.map.getCenter().lat.toFixed(4)},#{s.map.getCenter().lng.toFixed(4)},#{s.map.getZoom()}" )
        s.map.on "moveend", -> s.updateQuery()
        s.map.on "zoomend", -> 
          s.showHideContext()
          s.updateQuery()

  }
