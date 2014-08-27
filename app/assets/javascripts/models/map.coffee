# class Map

# # VECTOR LAYER STYLING

#   myVectorStyle = {zIndexing: true, zIndex: "16777250", strokeDashstyle: "dash", strokeColor: "#666666", strokeWidth: "2", strokeLinejoin: "miter"}
#   myMarkerStyle = {zIndexing: true, zIndex: "16777260"}
#   myMapStyle = {zoomWheelEnabled: false, DragPanEnabled: false, PinchZoomEnabled: false}

#   constructor: (mapId) ->
#     @mapId = mapId
#     @fromProjection = new OpenLayers.Projection("EPSG:4326") # Transform from WGS 1984
#     @toProjection = new OpenLayers.Projection("EPSG:900913") # to Spherical Mercator Projection
#     @mapnik = new OpenLayers.Layer.OSM()
#     @markers = new OpenLayers.Layer.Markers("Markers")

#   icon_size = new OpenLayers.Size(32,38)
#   icon_offset = new OpenLayers.Pixel(-(icon_size.w/2), -icon_size.h)
#   icon: -> new OpenLayers.Icon("/assets/timeline-cluster-pin.png", icon_size, icon_offset)

#   map: -> 
#     options = 
#       theme: '/assets/sections/map-theme.css'

#     new OpenLayers.Map("#{@mapId}-map", options, {style: myMapStyle})

#   markerCoordinates: -> $("\##{@mapId}-data").data('markers').split('+')
#   styles: -> 
#     new OpenLayers.Style 
#       'pointRadius': 30

#   paint: ->

#     map = @map()
#     map.addLayer(@mapnik)
#     map.addLayer(@markers)
#     window.m = map

# # CENTERING

#     max_lat = -90
#     min_lat = 90
#     max_lon = -180
#     min_lon = 180
#     average_lat = 0
#     average_lon = 0
#     start_point = 0
#     end_point = 0
#     for pair, index in @markerCoordinates()
#       end_point == pair
#       coords = pair.split(":")
#       if index == 0
#         start_point = new OpenLayers.Geometry.Point(coords[1],coords[0])
#       else
#         end_point = new OpenLayers.Geometry.Point(coords[1],coords[0])
#         ol = new OpenLayers.Layer.OSM()
#         vector = new OpenLayers.Layer.Vector('New Vector', {style: myVectorStyle})
#         vector.addFeatures([new OpenLayers.Feature.Vector(
#           new OpenLayers.Geometry.LineString([start_point, end_point]).transform(
#             new OpenLayers.Projection("EPSG:4326"), 
#             new OpenLayers.Projection("EPSG:900913")
#           )
#         )
#         ])
#         map.addLayers([ol,vector])
#         start_point = new OpenLayers.Geometry.Point(coords[1],coords[0])
#       pos = new OpenLayers.LonLat(coords[1], coords[0]).transform( @fromProjection, @toProjection )
#       @markers.addMarker(new OpenLayers.Marker( pos, @icon(), {style: myMarkerStyle}) )
#       if coords[0] > max_lat
#         max_lat = parseFloat(coords[0])
#       if coords[0] < min_lat
#         min_lat = parseFloat(coords[0])
#       if coords[1] > max_lon
#         max_lon = parseFloat(coords[1])
#       if coords[1] < min_lon
#         min_lon = parseFloat(coords[1])
#     average_lat = ( parseFloat(max_lat) + parseFloat(min_lat) ) / 2
#     average_lon = ( parseFloat(max_lon) + parseFloat(min_lon) ) / 2
#     center_pos = new OpenLayers.LonLat(average_lon, average_lat).transform( @fromProjection, @toProjection)
#     map.setCenter(center_pos, 8)
#     map.setOptions(restrictedExtent: map.getExtent())

# # DRAW LINES

# <<<<<<< Updated upstream
# =======

# >>>>>>> Stashed changes
# # NEED TO ADD FUNCTION TO GET US TO AUTO-ZOOM... UNCLEAR WHAT OPENLAYERS HAS FOR THIS, LOOKED UP
# # ALSO WANT TO AUTOCALC INCLUDING PIN SIZES

# window.Map = Map

# # ->

# #   $addLivePin ->
# <<<<<<< Updated upstream
# #     window.document.getElementbyId('')
# =======
# #     window.document.getElementbyId('')
# >>>>>>> Stashed changes
