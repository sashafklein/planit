# For generating a leg map (with connected, ordered points)
#
# Optional attrs: width, height, zoom, scroll_wheel_zoom, map_id
#    Without these, the map functions with defaults
#
# HAML Usage:
# %leg_map{ coordinates: 'lat:lon+lat:lon+lat:lon' }

angular.module("Common").directive 'legMap', (Map, F) ->
  restrict: 'E'
  transclude: true
  replace: true
  template: "<div><div ng_transclude=true ></div></div>"
  scope:
    coordinates: '@'
    width: '@'
    height: '@'
    zoom: '@'
    scrollWheelZoom: '@'
    doubleClickZoom: '@'
    zoomControl: '@'
    mapId: '@'

  link: (s, elem) ->
    s.points = []

    _(s.coordinates.split('+')).map (string) ->
      pair = string.split(':')
      s.points.push { lat: parseFloat(pair[0]), lon: parseFloat(pair[1]) }

    width = s.width || '450px'
    height = s.height || '450px'
    zoom = s.zoom || 18
    scrollWheelZoom = s.scrollWheelZoom || false
    doubleClickZoom = s.doubleClickZoom || false
    zoomControl = s.zoomControl || false
    mapId = s.mapId || "map#{_.random(10000)}"

    icon = L.icon
      iconUrl: '/assets/pin_sm_red_19x22.png',  
      iconSize:     [19, 22],
      iconAnchor:   [8, 22],
      popupAnchor:  [1, -15]
      # shadowSize:   [50, 64], // size of the shadow
      # shadowAnchor: [4, 62],  // the same for the shadow
      # popupAnchor:  [-3, -76] // point from which the popup should open relative to the iconAnchor

    centerLat = -> F.avgOfExtremes( _.pluck(s.points, 'lat') )

    centerLon = -> F.avgOfExtremes( _.pluck(s.points, 'lon') )

    s.legMap = L.map(mapId, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl } ).setView([centerLat(), centerLon()], zoom)
    
    L.tileLayer(Map.tiles(), {
      attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
      maxZoom: 18,
      minZoom: 2
    }).addTo(s.legMap)

    new L.Control.Zoom({ position: 'topright' }).addTo(s.legMap);

    s.legMap.featureLayer = for point in s.points
      L.marker([point.lat, point.lon], { icon: icon }).addTo(s.legMap).bindPopup("#{point.lat}:#{point.lon}")

    bounds = new L.LatLngBounds(s.points)
    s.legMap.fitBounds(bounds)

    polyline = L.polyline(s.points, {color: 'red', opacity: '0.4', dashArray: '1, 0, 5'}).addTo(s.legMap);
