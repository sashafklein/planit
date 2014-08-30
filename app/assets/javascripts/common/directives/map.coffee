# For generating a leg map (with connected, ordered points)
#
# Optional attrs: width, height, zoom, scroll_wheel_zoom, map_id
#    Without these, the map functions with defaults
#
# HAML Usage:
# %map{ coordinates: 'lat:lon+lat:lon+lat:lon', icon:  }

angular.module("Common").directive 'map', (MapOptions, F) ->
  restrict: 'E'
  transclude: true
  scope:
    type: '@'
    coordinates: '@'
    width: '@'
    height: '@'
    zoom: '@'
    scrollWheelZoom: '@'
    doubleClickZoom: '@'
    zoomControl: '@'
    mapId: '@'
    icon: '@'

  link: (s, elem) ->
    acceptedMapTypes = ['leg', 'detail', 'print']
    s.type = 'leg' unless _.contains(acceptedMapTypes, s.type)
    s.zoomLevel = -> if s.type == 'leg' then 18 else 17


    s.points = []

    _(s.coordinates.split('+')).map (string) ->
      pair = string.split(':')
      s.points.push { lat: parseFloat(pair[0]), lon: parseFloat(pair[1]) }

    width = s.width || '450px'
    height = s.height || '450px'
    zoom = s.zoom || s.zoomLevel()
    scrollWheelZoom = s.scrollWheelZoom || false
    doubleClickZoom = s.doubleClickZoom || false
    zoomControl = s.zoomControl || false
    mapId = s.mapId || "map#{_.random(10000)}"

    icon = MapOptions.icon(s.icon)

    centerLat = -> F.avgOfExtremes( _.pluck(s.points, 'lat') )
    centerLon = -> F.avgOfExtremes( _.pluck(s.points, 'lon') )

    s.map = L.map(mapId, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl } ).setView([centerLat(), centerLon()], zoom)
    
    showAttribution = if s.type == 'detail' then false else false
    L.tileLayer(MapOptions.tiles(), MapOptions.tileOptions(showAttribution)).addTo(s.map)

    s.map.featureLayer = for point in s.points
      L.marker([point.lat, point.lon], { icon: icon }).addTo(s.map).bindPopup("#{point.lat}:#{point.lon}")

    if s.type == 'print'
      bounds = new L.LatLngBounds(s.points)
      s.map.fitBounds(bounds)
    else if s.type == 'detail'
      showAttribution = false
    else
      bounds = new L.LatLngBounds(s.points)
      s.map.fitBounds(bounds)
      new L.Control.Zoom({ position: 'topright' }).addTo(s.map)

    polyline = L.polyline(s.points, {color: 'red', opacity: '0.4', dashArray: '1, 0, 5'}).addTo(s.map);
