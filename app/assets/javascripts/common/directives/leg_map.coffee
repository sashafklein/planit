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
    mapId: '@'

  link: (s, elem) ->
    s.points = []

    _(s.coordinates.split('+')).map (string) ->
      pair = string.split(':')
      s.points.push { lat: parseInt(pair[0]), lon: parseInt(pair[1]) }

    width = s.width || '450px'
    height = s.height || '450px'
    zoom = s.zoom || 5
    scrollWheelZoom = s.scrollWheelZoom || false
    mapId = s.mapId || "map#{_.random(10000)}"

    icon = L.icon
      iconUrl: '/assets/pin_sm_red_19x22.png'
      iconSize:     [19, 22]
      # shadowSize:   [50, 64], // size of the shadow
      # iconAnchor:   [22, 94], // point of the icon which will correspond to marker's location
      # shadowAnchor: [4, 62],  // the same for the shadow
      # popupAnchor:  [-3, -76] // point from which the popup should open relative to the iconAnchor

    centerLat = -> 
      lats = _(s.points).map (point) -> point.lat
      F.average( [_.min(lats), _.max(lats)] )

    centerLon = -> 
      lons = _(s.points).map (point) -> point.lon
      F.average( [_.min(lons), _.max(lons)] )

    s.legMap = L.map(mapId, { scrollWheelZoom: scrollWheelZoom } ).setView([centerLat(), centerLon()], zoom)
    
    L.tileLayer(Map.tiles(), {
      attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
      maxZoom: 18
    }).addTo(s.legMap)

    for point in s.points
      L.marker([point.lat, point.lon], { icon: icon }).addTo(s.legMap)

