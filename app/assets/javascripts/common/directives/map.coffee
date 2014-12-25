# For generating a leg map (with connected, ordered points)
#
# Optional attrs: width, height, zoom, scroll_wheel_zoom, map_id
#    Without these, the map functions with defaults
#
# HAML Usage:
# %map{ coordinates: 'lat:lon+lat:lon+lat:lon', names: 'name/+/name', ids: '###+###', type: 'type'  }

angular.module("Common").directive 'map', (MapOptions, F, API) ->
  uniqueId = 1
  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: "<div class='ng-map-div' ><div ng_transclude=true></div></div>"
    scope:
      type: '@'
      coordinates: '@'
      names: '@'
      ids: '@'
      path: '@'
      width: '@'
      height: '@'
      zoom: '@'
      scrollWheelZoom: '@'
      doubleClickZoom: '@'
      zoomControl: '@'
      minzoom: '@'
      maxzoom: '@'

    link: (s, elem) ->

      acceptedMapTypes = ['default', 'print']
      s.type = 'default' unless _.contains(acceptedMapTypes, s.type)
      s.zoomLevel = -> if s.type == 'default' then 17

      path_to_replace = s.path || ''
      s.link_path = path_to_replace.replace(path_to_replace.split('/')[path_to_replace.split('/').length-1], '') || ''

      ids_to_split = s.ids || ''
      s.point_ids = []
      _(ids_to_split.split('+')).map (string) ->
        s.point_ids.push string

      names_to_split = s.names || ''
      s.point_names = []
      _(names_to_split.split('/+/')).map (string) ->
        s.point_names.push string

      s.points = []
      _(s.coordinates.split('+')).map (string) ->
        pair = string.split(':')
        s.points.push { lat: parseFloat(pair[0]), lon: parseFloat(pair[1]) }

      width = s.width || '450px'
      height = s.height || false
      zoom = s.zoom || s.zoomLevel()
      scrollWheelZoom = s.scrollWheelZoom || false
      doubleClickZoom = s.doubleClickZoom || true
      zoomControl = s.zoomControl || false
      minZoom = s.minzoom || 1
      maxZoom = s.maxzoom || 17

      id = "map#{uniqueId++}"
      elem.attr('id', id)

      centerLat = -> F.avgOfExtremes( _.pluck(s.points, 'lat') )
      centerLon = -> F.avgOfExtremes( _.pluck(s.points, 'lon') )

      s.map = L.map(id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom } ).setView([centerLat(), centerLon()], zoom)
      
      # L.tileLayer(MapOptions.tiles(), MapOptions.tileOptions(s.type != 'detail')).addTo(s.map)
      L.tileLayer('http://otile1.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg',
        attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
      ).addTo(s.map)

      divIconContent = 'Test'

      if s.type == 'default' && s.points.length > 1
        i = 0
        s.map.featureLayer = for point in s.points
          i++
          L.marker([point.lat, point.lon], { 
            icon: L.divIcon({
              # // Specify a class name we can refer to in CSS.
              className: 'default-map-icon',
              # // Define what HTML goes in each marker.
              html: "<span class='default-map-icon-tab'><img src='/assets/map_icon_tip_red.png'><b>#{i}</b></span>",
              # // Set a markers width and height.
              iconSize: null,
              # riseOnHover: true,
              # riseOffset: 250,
              # zIndexOffset: 0,
              title: s.point_names[i-1],
              alt: s.point_names[i-1],
              })
          }).addTo(s.map).bindPopup("<a href='#{s.link_path}#{s.point_ids[i-1]}'>#{s.point_names[i-1]}</a>")
      else if s.type == 'default' && s.points.length == 1
        s.map.featureLayer = for point in s.points
          L.marker([point.lat, point.lon], { 
            icon: L.icon {
              iconUrl: '/assets/map_icon_x_black.png'
              iconSize: [15, 29]
              iconAnchor: [7, 15]
              }
          }).addTo(s.map)
      else if s.type == 'print' && s.points.length > 1
        i = 0
        s.map.featureLayer = for point in s.points
          i++
          L.marker([point.lat, point.lon], { 
            icon: L.divIcon({
              # // Specify a class name we can refer to in CSS.
              className: 'default-map-icon',
              # // Define what HTML goes in each marker.
              html: "<span class='default-map-icon-tab print'><img src='/assets/map_icon_tip_black.png'><b>#{i}</b></span>",
              # // Set a markers width and height.
              iconSize: null,
              })
          }).addTo(s.map)
      else if s.type == 'print' && s.points.length == 1
        s.map.featureLayer = for point in s.points
          L.marker([point.lat, point.lon], { 
            icon: L.icon {
              iconUrl: '/assets/map_icon_x_black.png'
              iconSize: [15, 29]
              iconAnchor: [7, 15]
              }
          }).addTo(s.map)

      if s.type == 'default' && s.points.length > 1
        s.bounds = new L.LatLngBounds(s.points)
        s.map.fitBounds(s.bounds, { padding: [25, 25] } )
        new L.Control.Zoom({ position: 'topright' }).addTo(s.map)
      else if s.type == 'default' && s.points.length == 1
        new L.Control.Zoom({ position: 'topright' }).addTo(s.map)
      else if s.type == 'print'
        s.bounds = new L.LatLngBounds(s.points)
        s.map.fitBounds(s.bounds, { padding: [25, 25] } )
        showAttribution = false

      unless _(['default', 'print']).contains s.type
        polyline = L.polyline(s.points, {color: 'red', opacity: '0.4', dashArray: '6, 10'}).addTo(s.map);

      this.featureLayer = (marker) ->
        marker.on "mouseover", ->
          marker.setZIndexOffset(2000)
        return
        marker.on "mouseout", ->
          marker.setZIndexOffset(7)
        return

  }