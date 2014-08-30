# For generating a leg map (with connected, ordered points)
#
# Optional attrs: width, height, zoom, scroll_wheel_zoom, map_id
#    Without these, the map functions with defaults
#
# HAML Usage:
# %map{ coordinates: 'lat:lon+lat:lon+lat:lon', icon:  }

angular.module("Common").directive 'map', (MapOptions, F) ->
  uniqueId = 1
  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: "<div class='ng-map-div' ><div ng_transclude=true></div></div>"
    scope:
      type: '@'
      coordinates: '@'
      width: '@'
      height: '@'
      zoom: '@'
      scrollWheelZoom: '@'
      doubleClickZoom: '@'
      zoomControl: '@'
      icon: '@'

    link: (s, elem) ->
      acceptedMapTypes = ['leg', 'detail', 'print']
      s.type = 'leg' unless _.contains(acceptedMapTypes, s.type)
      s.zoomLevel = -> if s.type == 'leg' then 18 else 16

      s.points = []

      _(s.coordinates.split('+')).map (string) ->
        pair = string.split(':')
        s.points.push { lat: parseFloat(pair[0]), lon: parseFloat(pair[1]) }

      width = s.width || '450px'
      height = s.height || false
      zoom = s.zoom || s.zoomLevel()
      scrollWheelZoom = s.scrollWheelZoom || false
      doubleClickZoom = s.doubleClickZoom || false
      zoomControl = s.zoomControl || false

      id = "map#{uniqueId++}"
      elem.attr('id', id)

      icon = MapOptions.icon(s.icon)

      centerLat = -> F.avgOfExtremes( _.pluck(s.points, 'lat') )
      centerLon = -> F.avgOfExtremes( _.pluck(s.points, 'lon') )

      s.map = L.map(id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl } ).setView([centerLat(), centerLon()], zoom)
      
      L.tileLayer(MapOptions.tiles(), MapOptions.tileOptions(s.type != 'detail')).addTo(s.map)

      s.map.featureLayer = for point in s.points
        L.marker([point.lat, point.lon], { icon: icon }).addTo(s.map).bindPopup("#{point.lat}:#{point.lon}")

      if s.type == 'print'
        s.bounds = new L.LatLngBounds(s.points)
        s.map.fitBounds(s.bounds)
      else if s.type == 'detail'
        showAttribution = false
      else
        s.bounds = new L.LatLngBounds(s.points)
        s.map.fitBounds(s.bounds)
        new L.Control.Zoom({ position: 'topright' }).addTo(s.map)

      polyline = L.polyline(s.points, {color: 'red', opacity: '0.4', dashArray: '1, 0, 5'}).addTo(s.map);
  }