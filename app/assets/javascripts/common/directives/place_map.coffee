angular.module("Common").directive 'placeMap', (MapOptions, F, API, Place) ->
  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: "<div class='ng-map-div'><div ng_transclude=true></div></div>"
    scope:
      placeId: '@'

    link: (scope, element) ->
      Place.find( scope.placeId )
        .success (place) ->
          scope.place = Place.generateFromJSON(place)
          scope.drawMap()
        .error (response) ->
          alert("Failed to grab place information!")
          console.log response

      scope.drawMap = () ->
        scope.place.name
  }


  # #     type: '@'
  # #     coordinates: '@'
  # #     names: '@'
  # #     ids: '@'
  # #     path: '@'
  # #     width: '@'
  # #     height: '@'
  # #     zoom: '@'
  # #     scrollWheelZoom: '@'
  # #     doubleClickZoom: '@'
  # #     zoomControl: '@'
  # #     minzoom: '@'
  # #     maxzoom: '@'

  # #   link: (s, elem) ->

  #     acceptedMapTypes = ['default', 'print', 'worldview']
  #     s.type = 'default' unless _.contains(acceptedMapTypes, s.type)
  #     s.zoomLevel = -> if s.type == 'worldview' then 1 || 17

  #     path_to_replace = s.path || ''
  #     s.link_path = path_to_replace.replace(path_to_replace.split('/')[path_to_replace.split('/').length-1], '') || ''

  #     ids_to_split = s.ids || ''
  #     s.point_ids = []
  #     _(ids_to_split.split('+')).map (string) ->  
  #       s.point_ids.push string

  #     names_to_split = s.names || ''
  #     s.point_names = []
  #     _(names_to_split.split('/+/')).map (string) ->
  #       s.point_names.push string

  #     s.points = []
  #     _(s.coordinates.split('+')).map (string) ->
  #       pair = string.split(':')
  #       s.points.push { lat: parseFloat(pair[0]), lon: parseFloat(pair[1]) }

  #     zoom = s.zoom || s.zoomLevel()
  #     scrollWheelZoom = s.scrollWheelZoom || false
  #     doubleClickZoom = s.doubleClickZoom || true
  #     zoomControl = s.zoomControl || false
  #     minZoom = s.minzoom || 1
  #     maxZoom = s.maxzoom || 18

  #     id = "map#{uniqueId++}"
  #     elem.attr('id', id)

  #     centerLat = -> F.avgOfExtremes( _.pluck(s.points, 'lat') )
  #     centerLon = -> F.avgOfExtremes( _.pluck(s.points, 'lon') )

  #     s.map = L.map(id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom } ).setView([centerLat(), centerLon()], zoom)
      
  #     # L.tileLayer(MapOptions.tiles(), MapOptions.tileOptions(s.type != 'detail')).addTo(s.map)
  #     L.tileLayer('http://otile1.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg',
  #       attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
  #     ).addTo(s.map)

  #     divIconContent = 'Test'

  #     if s.type == 'default' && s.points.length > 1
  #       clusterMarkers = new L.MarkerClusterGroup({
  #         maxClusterRadius: 70,
  #         iconCreateFunction: (cluster) ->
  #           markers = cluster.getAllChildMarkers()
  #           L.divIcon
  #             html: "<span class='cluster-map-icon-tab'>#{markers.length} pins</span>"
  #             className: "cluster-map-div-container"
  #         showCoverageOnHover: false
  #       })
  #       i = 0
  #       while i < s.points.length
  #         a = s.points[i]
  #         clusterMarker = L.marker(new L.LatLng(a.lat, a.lon), {
  #           icon: L.divIcon({
  #             className: 'default-map-div-icon',
  #             html: "<span class='default-map-icon-tab'><img src='/assets/map_icon_tip_red.png'><b>#{i+1}</b></span>",
  #             iconSize: null,
  #             title: s.point_names[i],
  #             alt: s.point_names[i],
  #           })
  #         }).bindPopup("<a href='#{s.link_path}#{s.point_ids[i]}'>#{s.point_names[i]}</a>", {offset: new L.Point(0,8)})
  #         clusterMarkers.addLayer clusterMarker
  #         i++
  #       s.map.addLayer(clusterMarkers)
  #     else if s.type == 'print' && s.points.length > 1
  #       i = 0
  #       s.map.featureLayer = for point in s.points
  #         i++
  #         L.marker([point.lat, point.lon], { 
  #           icon: L.divIcon({
  #             className: 'default-map-div-icon',
  #             html: "<span class='default-map-icon-tab print'><img src='/assets/map_icon_tip_black.png'><b>#{i}</b></span>",
  #             iconSize: null,
  #           })
  #         }).addTo(s.map)
  #     else if s.type == 'worldview'
  #       clusterMarkers = new L.MarkerClusterGroup({
  #         maxClusterRadius: 70,
  #         iconCreateFunction: (cluster) ->
  #           markers = cluster.getAllChildMarkers()
  #           L.divIcon
  #             html: "<span class='cluster-map-icon-tab'>#{markers.length} pins</span>"
  #             className: "cluster-map-div-container"
  #         showCoverageOnHover: false
  #       })
  #       i = 0
  #       while i < s.points.length
  #         a = s.points[i]
  #         clusterMarker = L.marker(new L.LatLng(a.lat, a.lon), {
  #           icon: L.divIcon({
  #             className: 'default-map-div-icon',
  #             html: "<span class='default-map-icon-tab'><img src='/assets/map_icon_tip_red.png'><i class='fa fa-globe'></i></span>",
  #             iconSize: null,
  #           })
  #         }).bindPopup("<a href='#{s.link_path}#{s.point_ids[i]}'>#{s.point_names[i]}</a>", {offset: new L.Point(0,8)})
  #         clusterMarkers.addLayer clusterMarker
  #         i++
  #       s.map.addLayer(clusterMarkers)
  #     else
  #       s.map.featureLayer = for point in s.points
  #         marker = L.marker([point.lat, point.lon], { 
  #           icon: L.icon {
  #             iconUrl: '/assets/map_icon_x_black.png',
  #             iconSize: [15, 29],
  #             iconAnchor: [7, 15],
  #           }
  #         }).on('click', (e) -> s.map.setView([point.lat,point.lon], 16) )
  #         marker.addTo(s.map)

  #     if s.type == 'default' && s.points.length > 1
  #       s.bounds = new L.LatLngBounds(s.points)
  #       s.map.fitBounds(s.bounds, { padding: [25, 25] } )
  #       new L.Control.Zoom({ position: 'topright' }).addTo(s.map)
  #     else if s.type == 'default' && s.points.length == 1
  #       s.map.setView([s.points[0].lat,s.points[0].lon], 16)
  #       new L.Control.Zoom({ position: 'topright' }).addTo(s.map)
  #     else if s.type == 'worldview' && s.points.length > 1
  #       s.bounds = new L.LatLngBounds(s.points)
  #       s.map.fitBounds(s.bounds, { padding: [25, 25] } )
  #       new L.Control.Zoom({ position: 'topright' }).addTo(s.map)
  #     else if s.type == 'print' && s.points.length == 1
  #       s.map.setView([s.points[0].lat,s.points[0].lon], 16)
  #       showAttribution = false
  #     else if s.type == 'print'
  #       s.bounds = new L.LatLngBounds(s.points)
  #       s.map.fitBounds(s.bounds, { padding: [25, 25] } )
  #       showAttribution = false

  #     unless _(['default', 'print', 'worldview']).contains s.type
  #       polyline = L.polyline(s.points, {color: 'red', opacity: '0.4', dashArray: '6, 10'}).addTo(s.map);

  #     this.featureLayer = (marker) ->
  #       marker.on "mouseover", ->
  #         marker.setZIndexOffset(2000)
  #       return
  #       marker.on "mouseout", ->
  #         marker.setZIndexOffset(7)
  # #       return

  # # }