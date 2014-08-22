class Map

  constructor: (mapId) ->
    @mapId = mapId
    @fromProjection = new OpenLayers.Projection("EPSG:4326") # Transform from WGS 1984
    @toProjection = new OpenLayers.Projection("EPSG:900913") # to Spherical Mercator Projection
    @mapnik = new OpenLayers.Layer.OSM()
    @markers = new OpenLayers.Layer.Markers("Markers")

  icon: -> new OpenLayers.Icon("/assets/timeline-cluster-pin.png")

  map: -> 
    options = 
      theme: '/assets/sections/map-theme.css'

    new OpenLayers.Map("#{@mapId}-map", options)

  markerCoordinates: -> $("\##{@mapId}-data").data('markers').split('+')
  styles: -> 
    new OpenLayers.Style 
      'pointRadius': 30

  paint: ->
    map = @map()
    map.addLayer(@mapnik)
    map.addLayer(@markers)
    window.m = map
    for pair in @markerCoordinates()
      coords = pair.split(":")
      pos = new OpenLayers.LonLat(coords[1], coords[0]).transform( @fromProjection, @toProjection )
      @markers.addMarker(new OpenLayers.Marker pos, @icon() )
      map.setCenter(pos, 8)

window.Map = Map