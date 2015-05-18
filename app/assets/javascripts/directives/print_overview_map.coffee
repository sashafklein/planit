angular.module("Common").directive 'printOverviewMap', (ErrorReporter, $timeout) ->

  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: "<div class='ng-map-div'><div ng_transclude=true></div></div>"
    scope:
      items: '='
      userId: '@'
      zoomControl: '@'

    link: (s, element) ->

      s.drawMap = (s, elem) ->

        scrollWheelZoom = false
        doubleClickZoom = true
        zoomControl = s.zoomControl || false
        minZoom = 1
        maxZoom = 12 

        id = "overview_map_#{ Math.floor((Math.random() * 10000) + 1) }"
        elem.attr('id', id)

        s.map = L.map( id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom } )
        
        L.tileLayer("https://otile#{ Math.floor(Math.random() * (4 - 1 + 1)) + 1 }-s.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg",
          attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
        ).addTo(s.map)

        placeCoordinates = []

        # Primary Pins in Clusters if Plan, WorldView
        # s.clusterMarkers = new L.MarkerClusterGroup({
        #   disableClusteringAtZoom: 13,
        #   spiderfyOnMaxZoom: true,
        #   maxClusterRadius: 80,
        #   iconCreateFunction: (cluster) ->
        #     L.divIcon( 
        #       className: "cluster-map-div-container",
        #       html: "<div class='cluster-map-icon-tab xsm'>*</div>",
        #       iconSize: new L.Point(18,18),
        #       iconAnchor: [9,9]
        #     )
        #   showCoverageOnHover: false,
        # })
        # i = 0
        s.placeMarkers = ->
          s.mapItems = s.items
          i = 0
          while i < s.mapItems.length
            item = s.mapItems[i]
            placeCoordinates.push [item.mark.place.lat,item.mark.place.lon]
            singleMarker = L.marker(new L.LatLng(item.mark.place.lat, item.mark.place.lon), {
              icon: L.divIcon({
                className: 'default-map-div-icon xsm',
                html: "<div class='default-map-icon-tab xsm highlighted' id='print_item_#{item.id}'></div>",
                iconSize: null,
              }),
              title: item.mark.place.name,
              alt: item.mark.place.name,
              itemId: item.id,
            }).bindPopup("#{item.mark.place.name}", {offset: new L.Point(0,0)})
            s.map.addLayer( singleMarker )
            i++

          s.bounds = new L.LatLngBounds(placeCoordinates)
          s.map.fitBounds(s.bounds, { padding: [25, 25] } )
          showAttribution = false

        s.placeMarkers()

      $timeout((-> s.drawMap( s, element ) ), 5000)

  }
