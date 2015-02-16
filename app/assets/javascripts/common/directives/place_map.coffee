angular.module("Common").directive 'placeMap', (F, Place, User, PlanitMarker) ->

  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: "<div class='ng-map-div'><div ng_transclude=true></div></div>"
    scope:
      placeId: '@'
      userId: '@'
      currentUserId: '@'
      type: '@'
      zoomControl: '@'

    link: (s, element) ->
      Place.find( s.placeId )
        .success (place) ->
          s.primaryPlace = Place.generateFromJSON(place)
          s.drawMap(s, element)
        .error (response) ->
          alert("Failed to grab place information!")
          console.log response

      s.generateContextualUserPins = ->
        User.findPlaces( s.currentUserId )
          .success (places) ->
            places = Place.generateFromJSON(places.current_user_pins)
            s.contextPlaces = _(places).select (place) ->
              s.primaryPlace.id != place.id
            for contextPlace in s.contextPlaces.value()
              PlanitMarker.contextPin(contextPlace).addTo(s.contextGroup)
          .error (response) ->
            alert("Failed to grab current user's other places!")
            console.log response

      s.drawMap = (s, elem) ->

        # Set map attributes & build map
        s.type = 'default' unless s.type == 'print'
        scrollWheelZoom = false unless s.scrollWheelZoom
        doubleClickZoom = true
        zoomControl = s.zoomControl || false
        minZoom = 7
        maxZoom = 18
        id = "map#{s.primaryPlace.id}"
        elem.attr('id', id)
        s.map = L.map(id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom } )

        # Tiles
        L.tileLayer('http://otile1.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg', attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>").addTo(s.map)

        # Create primary layer and pins
        featureLayer = PlanitMarker.primaryPin( s.primaryPlace, false ).on('click', (e) -> s.map.setView( [s.primaryPlace.lat,s.primaryPlace.lon], 16 ) )
        featureLayer.addTo(s.map)

        # Center and add features (zoom, attribution)
        s.map.setView( [s.primaryPlace.lat,s.primaryPlace.lon], 16 )
        # s.map.setMaxBounds(s.map.getBounds().pad(9))
        if s.type == 'print'
          showAttribution = false
        else
          new L.Control.Zoom({ position: 'topright' }).addTo(s.map)

        # Create context layer and pins
        s.contextGroup = L.layerGroup()
        s.map.addLayer(s.contextGroup)
        s.generateContextualUserPins() if s.currentUserId

        # Control whether or not context pins are viewable
        s.showHideContext = () ->
          if s.map.getZoom() > 11
            s.map.addLayer(s.contextGroup)
          else
            s.map.removeLayer(s.contextGroup)
        s.showHideContext()
        s.map.on "zoomend", -> s.showHideContext()

  }