angular.module("Common").directive 'printMap', (MapOptions, F, API, Place, User) ->

  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: "<div class='ng-map-div'><div ng_transclude=true></div></div>"
    scope:
      placeIds: '@'
      userId: '@'
      zoomControl: '@'

    link: (scope, element) ->
      scope.placeIds = JSON.parse(scope.placeIds)
      Place.where({ id: scope.placeIds })
        .success (places) ->
          scope.places = Place.generateFromJSON(places)
          scope.drawMap(scope, element)
        .error (response) ->
          alert("Failed to grab places information!")
          console.log response

      scope.drawMap = (scope, elem) ->

        scrollWheelZoom = false
        doubleClickZoom = true
        zoomControl = scope.zoomControl || false
        minZoom = 1
        maxZoom = 18

        id = "main_map"
        elem.attr('id', id)

        scope.map = L.map(id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom } )
        
        L.tileLayer('http://otile1.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg',
          attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
        ).addTo(scope.map)

        place_coordinates = []

        # Primary Pins in Clusters if Plan, WorldView
        clusterMarkers = new L.MarkerClusterGroup({
          maxClusterRadius: 80,
          iconCreateFunction: (cluster) ->
            markers = cluster.getAllChildMarkers()
            L.divIcon
              html: "<span class='cluster-map-icon-tab'>#{markers.length} pins</span>"
              className: "cluster-map-div-container"
          showCoverageOnHover: false
        })
        i = 0
        while i < scope.places.length
          a = scope.places[i]
          place_coordinates.push [a.lat,a.lon]
          clusterMarker = L.marker(new L.LatLng(a.lat, a.lon), {
            icon: L.divIcon({
              className: 'default-map-div-icon',
              html: "<span class='default-map-icon-tab'><img src='/assets/map_icon_tip_red.png'>#{catIconFor(a.metacategories)}</span>",
              iconSize: null,
              title: a.names[0],
              alt: a.names[0],
            })
          }).bindPopup("<a href='/places/#{a.id}'>#{a.names[0]}</a>", {offset: new L.Point(0,8)})
          clusterMarkers.addLayer clusterMarker
          i++
        scope.map.addLayer(clusterMarkers)

        scope.bounds = new L.LatLngBounds(place_coordinates)
        scope.map.fitBounds(scope.bounds, { padding: [25, 25] } )
        showAttribution = false

  }
