angular.module("Directives").directive 'placeOptionsMap', (F, Place, User, PlanitMarker, ClusterLocator, BasicOperators, ClickControls, $compile, $timeout) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    scope:
      markId: '@'
      currentUserId: '@'
      type: '@'
      zoomControl: '@'
      scrollWheelZoom: '@'

    link: (s, element) ->

      s.padding = [35, 25, 15, 25] # default

      # Mark.findPlaceOptions( s.markId )
      #   .success (places) -> 
      #     s.primaryPlacesRaw = Place.generateFromJSON(places.user_pins)
      #     s.filterPlaces( s.primaryPlacesRaw )
      #     s.drawMap(s, element)
      #   .error (response) ->
      #     console.log("Failed to grab places information!")
      #     console.log response

      s.drawMap = (s, elem) ->

        scrollWheelZoom = false unless s.scrollWheelZoom
        doubleClickZoom = true
        zoomControl = s.zoomControl || false
        minZoom = 2
        maxZoom = 18

        id = "place_option_map"
        elem.attr('id', id)

        s.map = L.map(id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom, maxBounds: [[-84,-400],[84,315]] } )
        
        L.tileLayer("https://otile#{ Math.floor(Math.random() * (4 - 1 + 1)) + 1 }-s.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg",
          attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
        ).addTo(s.map)

        s.map.setView( [0,0], 2 )

  }