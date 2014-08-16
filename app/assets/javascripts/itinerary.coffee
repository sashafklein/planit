$ ->

  $(window).scroll ->
    if ( $(@).scrollTop() > 1 )  
      $('persistent_header').addClass("sticky")
    else
      $('persistent_header').removeClass("sticky")

  # For Map
  markerCoordinates = $('#map-data').data('markers').split('+')

  fromProjection = new OpenLayers.Projection("EPSG:4326") # Transform from WGS 1984
  toProjection   = new OpenLayers.Projection("EPSG:900913") # to Spherical Mercator Projection

  map = new OpenLayers.Map("map")
  mapnik = new OpenLayers.Layer.OSM()
  map.addLayer(mapnik)
  
  markers = new OpenLayers.Layer.Markers( "Markers" )
  map.addLayer(markers)
  
  for coordinate in markerCoordinates
    lat = coordinate.split(':')[0]
    lon = coordinate.split(':')[1]
    pos = new OpenLayers.LonLat(lon, lat).transform( fromProjection, toProjection )

    markers.addMarker(new OpenLayers.Marker(pos))
    map.setCenter(pos, 8)

  