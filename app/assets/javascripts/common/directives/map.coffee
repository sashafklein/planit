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
      acceptedMapTypes = ['allitems', 'allitemsdense', 'leg', 'day', 'daydense', 'detail', 'print', 'printdense', 'legdense']
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
      
      # L.tileLayer(MapOptions.tiles(), MapOptions.tileOptions(s.type != 'detail')).addTo(s.map)
      L.tileLayer('http://otile1.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg',
        attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
      ).addTo(s.map)

      Popup = L.popup({
        closeButton: false
        offset: [5, 3]
        closeOnClick: false
        className: 'leg-map-icon-tab'
        })

      divIconContent = 'Test'

      if s.type == 'leg' || s.type == 'legdense'
        # s.map.backgroundLayer = for point in s.points
        #   L.marker([point.lat, point.lon], { 
        #     icon: L.icon {
        #       iconUrl: '/assets/map_dot_5x5.png'
        #       iconSize: [5, 5]
        #       iconAnchor: [2, 2]
        #       })
        #   }).addTo(s.map)
        s.map.featureLayer = for point in s.points
          L.marker([point.lat, point.lon], { 
            icon: L.divIcon({
              # // Specify a class name we can refer to in CSS.
              className: 'leg-map-icon',
              # // Define what HTML goes in each marker.
              html: "<span class='leg-map-icon-tab'><img src='/assets/leg-map-icon-tip-red.png'>#{divIconContent}</span>",
              # // Set a markers width and height.
              iconSize: null,
              riseOnHover: true,
              riseOffset: 250,
              # zIndexOffset: 0,
              title: 'test',
              alt: 'test2'
              })
          }).addTo(s.map).bindPopup("#{point.name}")

      else if s.type == 'day' || s.type == 'day'
        s.map.featureLayer = for point in s.points
          L.marker([point.lat, point.lon], { 
            icon: L.divIcon({
              # // Specify a class name we can refer to in CSS.
              className: 'day-map-icon',
              # // Define what HTML goes in each marker.
              html: "<div class='day-map-icon-tab'><img src='/assets/day-map-icon-tip-dark.png'>J</div>",
              # // Set a markers width and height.
              iconSize: [18, 24]
              iconAnchor: [9, 24]
              # riseOnHover: true
              # riseOffset: 250
              })
          }).addTo(s.map)
      else
        s.map.featureLayer = for point in s.points
          L.marker([point.lat, point.lon], { icon: icon }).addTo(s.map).bindPopup("#{point.lat}:#{point.lon}")

      if s.type == 'print'
        s.bounds = new L.LatLngBounds(s.points)
        s.map.fitBounds(s.bounds, { padding: [15, 15] } )
      else if s.type == 'detail'
        showAttribution = false
      else if s.type == 'mega'
        s.bounds = new L.LatLngBounds(s.points)
        s.map.fitBounds(s.bounds, { 
          paddingTopLeft: [85, 350],
          paddingBottomRight: [15, 350]
        } )
        new L.Control.Zoom({ position: 'bottomright' }).addTo(s.map)
      else
        s.bounds = new L.LatLngBounds(s.points)
        s.map.fitBounds(s.bounds, { padding: [15, 15] } )
        new L.Control.Zoom({ position: 'topright' }).addTo(s.map)

      unless _(['detail', 'day', 'daydense', 'printdense', 'legdense']).contains s.type
        polyline = L.polyline(s.points, {color: 'red', opacity: '0.4', dashArray: '6, 10'}).addTo(s.map);

      this.featureLayer = (marker) ->
        marker.on "mouseover", ->
          marker.setZIndexOffset(2000)
        return
        marker.on "mouseout", ->
          marker.setZIndexOffset(7)
        return

  }