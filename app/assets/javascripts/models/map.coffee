class Map

  constructor: (mapId) ->
    @mapId = mapId
    @fromProjection = new OpenLayers.Projection("EPSG:4326") # Transform from WGS 1984
    @toProjection = new OpenLayers.Projection("EPSG:900913") # to Spherical Mercator Projection
    @mapnik = new OpenLayers.Layer.OSM()
    @markers = new OpenLayers.Layer.Markers("Markers")

  icon_size = new OpenLayers.Size(55,55)
  icon_offset = new OpenLayers.Pixel(-(icon_size.w/2), -icon_size.h)
  icon: -> new OpenLayers.Icon("/assets/timeline-cluster-pin.png", icon_size, icon_offset)

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

# NIKO'S HACKY CENTERING 

    max_lat = -90
    min_lat = 90
    max_lon = -180
    min_lon = 180
    average_lat = 0
    average_lon = 0
    for pair in @markerCoordinates()
      coords = pair.split(":")
      pos = new OpenLayers.LonLat(coords[1], coords[0]).transform( @fromProjection, @toProjection )
      @markers.addMarker(new OpenLayers.Marker pos, @icon() )
      if coords[0] > max_lat
        max_lat = parseFloat(coords[0])
      if coords[0] < min_lat
        min_lat = parseFloat(coords[0])
      if coords[1] > max_lon
        max_lon = parseFloat(coords[1])
      if coords[1] < min_lon
        min_lon = parseFloat(coords[1])
    average_lat = ( parseFloat(max_lat) + parseFloat(min_lat) ) / 2
    average_lon = ( parseFloat(max_lon) + parseFloat(min_lon) ) / 2
    center_pos = new OpenLayers.LonLat(average_lon, average_lat).transform( @fromProjection, @toProjection)
    map.setCenter(center_pos, 8)
    map.setOptions(restrictedExtent: map.getExtent())
# NEED TO ADD FUNCTION TO GET US TO AUTO-ZOOM... UNCLEAR WHAT OPENLAYERS HAS FOR THIS, LOOKED UP
# ALSO WANT TO AUTOCALC INCLUDING PIN SIZES

window.Map = Map

->

  $addLivePin ->
    window.document.getElementbyId('')