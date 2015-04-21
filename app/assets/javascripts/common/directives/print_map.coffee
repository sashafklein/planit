angular.module("Common").directive 'printMap', (F, Place, User) ->

  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: "<div class='ng-map-div'><div ng_transclude=true></div></div>"
    scope:
      items: '='
      locale: '='
      localeLevel: '='
      userId: '@'
      zoomControl: '@'

    link: (s, element) ->

      s.drawMap = (s, elem) ->

        scrollWheelZoom = false
        doubleClickZoom = true
        zoomControl = s.zoomControl || false
        minZoom = 1
        maxZoom = 12 

        id = "main_map_#{ Math.floor((Math.random() * 10000) + 1) }"
        elem.attr('id', id)

        s.map = L.map( id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom } )
        
        L.tileLayer("https://otile#{ Math.floor(Math.random() * (4 - 1 + 1)) + 1 }-s.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg",
          attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
        ).addTo(s.map)

        placeCoordinates = []
        if s.localeLevel == 'sublocality' then s.mapItems = _.filter( s.items, (i) -> i.mark.place.sublocality == s.locale )
        if s.localeLevel == 'locality' then s.mapItems = _.filter( s.items, (i) -> i.mark.place.locality == s.locale )
        if s.localeLevel == 'region' then s.mapItems = _.filter( s.items, (i) -> i.mark.place.region == s.locale )
        if s.localeLevel == 'country' then s.mapItems = _.filter( s.items, (i) -> i.mark.place.country == s.locale )

        # Primary Pins in Clusters if Plan, WorldView
        s.clusterMarkers = new L.MarkerClusterGroup({
          disableClusteringAtZoom: 13,
          spiderfyOnMaxZoom: true,
          maxClusterRadius: 80,
          iconCreateFunction: (cluster) ->
            L.divIcon( 
              className: "cluster-map-div-container",
              html: "<div class='cluster-map-icon-tab xsm'>*</div>",
              iconSize: new L.Point(18,18),
              iconAnchor: [9,9]
            )
          showCoverageOnHover: false,
        })
        i = 0
        while i < s.mapItems.length
          item = s.mapItems[i]
          placeCoordinates.push [item.mark.place.lat,item.mark.place.lon]
          clusterMarker = L.marker(new L.LatLng(item.mark.place.lat, item.mark.place.lon), {
            icon: L.divIcon({
              className: 'default-map-div-icon xsm',
              html: "<div class='default-map-icon-tab xsm highlighted' id='print_item_#{item.id}'>*</div>",
              iconSize: null,
            }),
            title: item.mark.place.name,
            alt: item.mark.place.name,
            itemId: item.id,
          }).bindPopup("#{item.mark.place.name}", {offset: new L.Point(0,0)})
          s.clusterMarkers.addLayer clusterMarker
          i++
        s.map.addLayer(s.clusterMarkers)

        s.bounds = new L.LatLngBounds(placeCoordinates)
        s.map.fitBounds(s.bounds, { padding: [25, 25] } )
        showAttribution = false

        window.pm = s

        # Numbering & Lettering
        clusterCount = 0
        markerCount = 0
        _.forEach( s.clusterMarkers._featureGroup._layers, (layer) -> 
          if layer._markers?.length
            clusterCount++
            letterCount = String.fromCharCode( clusterCount + 96 ).toUpperCase()
            _.forEach( layer._markers, (marker) ->
              _.map( _.filter( s.items, (i) -> i.id == marker.options.itemId ), (i) -> i.symbol = letterCount )
            )
            layer._icon.innerHTML = layer._icon.innerHTML.replace("*", letterCount )
          else if layer._childClusters?.length
            clusterCount++
            letterCount = String.fromCharCode( clusterCount + 96 ).toUpperCase()
            # recursively comb through layers with _childClusters until arrive at one with _markers?.length
            # then in that layer, 
            # _.forEach( layer._markers, (marker) ->
            #   _.map( _.filter( s.items, (i) -> i.id == marker.options.itemId ), (i) -> i.symbol = letterCount )
            # )
            layer._icon.innerHTML = layer._icon.innerHTML.replace("*", letterCount )            
          else
            markerCount++
            _.map( _.filter( s.items, (i) -> i.id == layer.options.itemId ), (i) -> i.symbol = markerCount )
            layer._icon.innerHTML = layer._icon.innerHTML.replace("*", markerCount )
        )

      s.drawMap( s, element )

  }
