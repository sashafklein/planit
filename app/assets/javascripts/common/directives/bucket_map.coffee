angular.module("Common").directive 'bucketMap', (F, Place, User, PlanitMarker, ClusterLocator, BasicOperators, ClickControls, QueryString, PlaceFilterer, $compile, $timeout) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "bucket_map.html"
    scope:
      userId: '@'
      currentUserId: '@'
      type: '@'
      zoomControl: '@'
      scrollWheelZoom: '@'
      webPadding: '@'
      mobilePadding: '@'
      showList: '@'

    link: (s, element) ->

      s.showList = true unless s.showList
      s.mobile = if element.width() < 768 then true else false
      s.padding = [35, 25, 15, 25] # default
      s.requireDoubleClick = if s.mobile then true else false

      User.findPlaces( s.userId )
        .success (places) -> 
          s.primaryPlacesRaw = Place.generateFromJSON(places.user_pins)
          s.filterPlaces( s.primaryPlacesRaw )
          s.drawMap(s, element)
        .error (response) ->
          console.log("Failed to grab places information!")
          console.log response

      if s.mobilePadding && s.mobile
        s.padding = JSON.parse("[" + s.mobilePadding + "]")
      else if s.webPadding && !s.mobile
        s.padding = JSON.parse("[" + s.webPadding + "]")

      s.filterPlaces = (places) ->
        s.primaryPlaces = PlaceFilterer.returnFiltered( places )

      s.drawMap = (s, elem) ->

        # Cluster Locator Functions
        s.bestListLocation = (places, center) ->
          location = BasicOperators.commaAndJoin( _(places).map('names').map((p) -> p[0]).value() ) if places.length < 3
          location ||= Place.lowestCommonArea(places)
          location ||= ClusterLocator.nearestGlobalRegion(center)
          return location

        # Disable Map Panning & Zooming for List Box or Item Box
        fixInfoBox = () ->
          s.infoBox = if !s.mobile then document.getElementById('in-view-list') else document.getElementById('in-view-item')
          s.infoBox.addEventListener 'mouseover', -> 
            s.map.dragging.disable()
            s.map.doubleClickZoom.disable()
          s.infoBox.addEventListener 'mouseout', -> 
            s.map.dragging.enable()
            s.map.doubleClickZoom.disable()
        setTimeout ( -> fixInfoBox() ), 1000

        s.generateContextualUserPins = ->
          if s.currentUserId != s.userId
            User.findPlaces( s.currentUserId )
              .success (places) ->
                places = Place.generateFromJSON(places.current_user_pins)
                s.contextPlaces = _(places).select (place) ->
                  !_( _( s.primaryPlaces ).map('id') ).contains( place.id )
                for contextPlace in s.contextPlaces.value()
                  PlanitMarker.contextPin(contextPlace).addTo(s.contextGroup)
              .error (response) ->
                alert("Failed to grab current user's other places!")
                console.log response

        scrollWheelZoom = false unless s.scrollWheelZoom
        doubleClickZoom = true
        zoomControl = s.zoomControl || false
        minZoom = 2
        maxZoom = 18

        id = "main_map"
        elem.attr('id', id)

        s.map = L.map(id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom, maxBounds: [[-84,-400],[84,315]] } )
        
        L.tileLayer('http://otile1.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg',
          attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
        ).addTo(s.map)

        # s.map.setView( [0,0], 2 )
          
        # Initialize and Execute hoverEvents
        s.webHoverEvents = (object, id) ->
          object.addEventListener 'mouseover', -> $timeout -> 
            $(element.find(".#{id}")).addClass('highlighted')
            unless object.className.indexOf('bucket-list-li') != -1
              $timeout ->
                $('#in-view-list').animate({
                  scrollTop: $("##{id}").offset().top - $('#top-of-list').offset().top
                }, 0)
          object.addEventListener 'mouseout', -> $timeout -> $(element.find(".#{id}")).removeClass('highlighted')
        s.doubleClickEvents = (object, id) ->
          object.addEventListener 'dblclick', -> 
            document.location.href = '/places/' + id.split('p')[1] if id
        s.clickPinEvents = (object, id) -> 
          object.addEventListener 'click', -> s.$apply ->
            $(element.find(".#{s.clickedId}")).removeClass('highlighted') if (s.clickedId && (s.clickedId != id) )
            $(element.find(".#{id}")).addClass('highlighted')
            s.clickedId = id
            s.place = if (id.split('p') && id.split('p').length > 1) then _(s.primaryPlaces).find( (obj) -> obj.id == parseInt( id.split('p')[1]) ) else null
            s.cluster = if (id.split('c') && id.split('c').length > 1) then s._clusterObject( clusterMarkers._featureGroup.getLayer( parseInt( id.split('c')[1] ) ) ) else null
        s.clickControlEvents = (object, id) ->
          object.addEventListener 'click', -> 
            ClickControls.placeEdits( $(this).attr('id'), $(this).attr('data-place-ids') )
        s.addMouseEvents = (arrayOfClasses, focus_on) ->
          $timeout -> 
            for className in arrayOfClasses
              for item in element.find(className)
                s.webHoverEvents( item, $(item).attr('id') ) if focus_on == 'hover'
                s.clickPinEvents( item, $(item).attr('id') ) if focus_on == 'clickPin'
                s.clickControlEvents( item, $(item).attr('id') ) if focus_on == 'clickControl'
                s.doubleClickEvents( item, $(item).attr('id') ) if focus_on == 'dblclick'

        # Create context layer and pins
        s.contextGroup = L.layerGroup()
        s.map.addLayer(s.contextGroup)
        s.generateContextualUserPins() if s.currentUserId

        # Primary Pins in Clusters if Plan, WorldView
        clusterMarkers = new L.MarkerClusterGroup({
          maxClusterRadius: 50,
          requireDoubleClick: s.requireDoubleClick,
          showCoverageOnHover: true,
          disableClusteringAtZoom: 15,
          spiderfyDistanceMultiplier: 2,
          polygonOptions: { color: '#ff0066', opacity: 1.0, fillColor: '#ff0066', fillOpacity: 0.4, weight: 3 },
          paddingToFocusArea: s.padding,
          iconCreateFunction: (cluster) -> PlanitMarker.clusterPin( cluster ),
        }) 
        i = 0
        s.primaryCoordinates = []
        while i < s.primaryPlaces.length
          place = s.primaryPlaces[i]
          place.leafletLocation = new L.LatLng( place.lat, place.lon )
          s.primaryCoordinates.push [place.lat,place.lon]
          clusterMarker = PlanitMarker.primaryPin(place)
          clusterMarkers.addLayer clusterMarker
          i++
        s.map.addLayer(clusterMarkers)

        # Start map (either center or with QueryString) and inject zoom control
        queryCenter = QueryString.get()["m"]
        if queryCenter && !queryCenter.replace(/[-0-9.,]/g,'').length && queryCenter.split(',').length == 3
          queryCenter = { lat: queryCenter.split(',')[0], lon: queryCenter.split(',')[1], zoom: queryCenter.split(',')[2] }
          s.map.setView( [ parseFloat( queryCenter.lat ), parseFloat( queryCenter.lon ) ], parseInt( queryCenter.zoom ) )
        else
          s.totalBounds = new L.LatLngBounds(s.primaryCoordinates)
          s.map.fitBounds(s.totalBounds, { paddingTopLeft: [s.padding[3], s.padding[0]], paddingBottomRight: [s.padding[1], s.padding[2]] } )
        new L.Control.Zoom({ position: 'topright' }).addTo(s.map)

        # Control whether or not context pins are viewable
        s.showHideContext = () ->
          if s.map.getZoom() > 11
            s.map.addLayer(s.contextGroup)
          else
            s.map.removeLayer(s.contextGroup)
        s.showHideContext()
        s.map.on "zoomend", -> s.showHideContext()

        # Retrieve Cluster Info and Produce Object
        s.currentBounds = -> s.map.getBounds()
        s._clusterObject = (cluster) ->
          places = _( cluster.getAllChildMarkers() ).map('options').map('placeObject').value()
          center = cluster._latlng
          return { id: "c#{cluster._leaflet_id}", count: cluster._childCount, center: center, places: places, location: s.bestListLocation(places, center), clusterObject: cluster }

        s.updateQuery = ->
          centerMap = s.map.getCenter()
          QueryString.modify( m: "#{centerMap.lat.toFixed(4)},#{centerMap.lng.toFixed(4)},#{s.map.getZoom()}" )

        if s.mobile
          # Relay clicked marker to infoBox if Mobile
          s.clickedId = undefined
          s.clearClicked = () -> 
            s.$apply ->
              $(element.find(".#{s.clickedId}")).removeClass('highlighted')
              s.clickedId = undefined 
              s.cluster = undefined
              s.place = undefined
          s.mobileUpdateView = () -> 
            s.addMouseEvents([".cluster-map-icon-tab", ".default-map-icon-tab", ".context-map-icon-tab"], 'clickPin')
            s.addMouseEvents([".default-map-icon-tab", ".context-map-icon-tab"], 'dblclick')
            s.addMouseEvents([".edit-place", ".edit-places"], 'clickControl')
            if ( (s.cluster && !s.currentBounds().contains( s.cluster.clusterObject._bounds ) ) || ( s.place && !s.currentBounds().contains( s.place.leafletLocation ) ) ) then s.clearClicked()
            s.updateQuery()
          s.map.on "moveend", -> s.mobileUpdateView()
          s.map.on "zoomend", -> setTimeout ( -> s.mobileUpdateView() ), 400
          s.mobileUpdateView()

        if !s.mobile
          # Relay back sidelist marker info if Web Browser
          s.webUpdateView = () -> 
            currentBounds = s.currentBounds()
            stuffOnMap = clusterMarkers._featureGroup.getLayers()
            s.placesInView = []
            s.clustersInView = []
            for layer in stuffOnMap
              s.placesInView.push( layer.options.placeObject ) if layer.options.placeObject && currentBounds.contains( layer._latlng )
              s.clustersInView.push( s._clusterObject(layer) ) if layer._childCount > 1 && currentBounds.contains( layer._bounds )
            if s.placesInView.length == 0 && s.clustersInView.length == 0
              $(element.find("#first-bucket-item")).removeClass('invisible')
            else
              $(element.find("#first-bucket-item")).addClass('invisible')
            s.clustersInView.sort( BasicOperators.dynamicSort('-count') )
            $timeout ->
              $('#in-view-list').animate({
                scrollTop: $('#first-bucket-item').offset().top
              }, 0)
            s.addMouseEvents([".cluster-map-icon-tab", ".default-map-icon-tab", ".bucket-list-li"], 'hover')
            s.addMouseEvents([".cluster-map-icon-tab", ".default-map-icon-tab", ".context-map-icon-tab"], 'dblclick')
            s.addMouseEvents([".edit-place", ".edit-places"], 'clickControl')
            s.updateQuery()
          s.map.on "moveend", -> s.webUpdateView()
          s.map.on "zoomend", -> setTimeout ( -> s.$apply -> s.webUpdateView() ), 400
          s.webUpdateView()
          # Change Initial Loading Tab for Future Viewing, Recenter 'Lost' Browser to Start
          $(element.find("#no-items-msg")).html('Not All Who Wander Are Lost...')
          element.find("#first-bucket-item")[0].addEventListener 'click', -> s.map.fitBounds(s.totalBounds, { paddingTopLeft: [s.padding[3], s.padding[0]], paddingBottomRight: [s.padding[1], s.padding[2]] } )

  }