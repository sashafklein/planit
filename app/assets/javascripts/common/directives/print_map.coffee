angular.module("Common").directive 'printMap', (F, Place, User) ->

  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: "<div class='ng-map-div'><div ng_transclude=true></div></div>"
    scope:
      placeIds: '@'
      userId: '@'
      zoomControl: '@'
      mapIndex: '@'
      idHash: '=?'

    link: (scope, element) ->

      scope.idHash = if scope.idHash then scope.idHash else {}
      scope.placeIds = JSON.parse(scope.placeIds)
      Place.where({ id: scope.placeIds })
        .success (places) ->
          scope.places = Place.generateFromJSON(places)
          scope.drawMap(scope, element)
        .error (response) ->
          console.log("Failed to grab places information!")
          console.log response

      scope.drawMap = (scope, elem) ->

        scrollWheelZoom = false
        doubleClickZoom = true
        zoomControl = scope.zoomControl || false
        minZoom = 1
        maxZoom = 12 

        id = "main_map_#{ scope.mapIndex }"
        elem.attr('id', id)

        scope.map = L.map(id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom } )
        
        L.tileLayer("https://otile#{ Math.floor(Math.random() * (4 - 1 + 1)) + 1 }-s.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg",
          attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
        ).addTo(scope.map)

        place_coordinates = []

        # Primary Pins in Clusters if Plan, WorldView
        scope.clusterMarkers = new L.MarkerClusterGroup({
          disableClusteringAtZoom: 13,
          spiderfyOnMaxZoom: true,
          maxClusterRadius: 80,
          iconCreateFunction: (cluster) ->
            L.divIcon( 
              className: "cluster-map-div-container",
              html: "<div class='cluster-map-icon-tab xsm'>*</div>",
              iconSize: new L.Point(18,18),
              iconAnchor: [9,9]
            )
          showCoverageOnHover: false,
        })
        i = 0
        while i < scope.places.length
          place = scope.places[i]
          place_coordinates.push [place.lat,place.lon]
          clusterMarker = L.marker(new L.LatLng(place.lat, place.lon), {
            icon: L.divIcon({
              className: 'default-map-div-icon xsm',
              html: "<div class='default-map-icon-tab xsm highlighted' id='print_item_#{place.id}'>*</div>",
              iconSize: null,
            }),
            title: place.name,
            alt: place.name,
            placeId: place.id,
          }).bindPopup("<a href='/places/#{place.id}' target='_self'>#{place.name}</a>", {offset: new L.Point(0,0)})
          scope.clusterMarkers.addLayer clusterMarker
          i++
        scope.map.addLayer(scope.clusterMarkers)

        scope.bounds = new L.LatLngBounds(place_coordinates)
        scope.map.fitBounds(scope.bounds, { padding: [25, 25] } )
        showAttribution = false

        window.pm = scope

        # Numbering & Lettering
        clusterCount = 0
        markerCount = 0
        _.forEach( scope.clusterMarkers._featureGroup._layers, (layer) -> 
          if layer._markers?.length
            clusterCount++
            _.forEach( layer._markers, (marker) ->
              scope.idHash[marker.options.placeId] = String.fromCharCode( clusterCount + 96 ).toUpperCase()
            )
            layer._icon.innerHTML = layer._icon.innerHTML.replace("*", String.fromCharCode( clusterCount + 96 ).toUpperCase() )
          else
            markerCount++
            scope.idHash[layer.options.placeId] = markerCount
            layer._icon.innerHTML = layer._icon.innerHTML.replace("*", markerCount )
        )

  }
