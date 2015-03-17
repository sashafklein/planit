angular.module("Common").directive 'bucketMap', (Place, User, PlanitMarker, leafletBoundsHelpers, leafletData, F, BasicOperators, ClusterLocator, BucketEventManager, $timeout, QueryString, PlaceFilterer) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'bucket_map.html'
    scope:
      userId: '@'
      currentUserId: '@'
      centerPoint: '@'

    # TODO 
    # - All who wander
    # - Side bar scroll
    # - Remove reusable stuff into more general directives (or rename?)
    link: (s, elem) ->
      s.marker = new PlanitMarker(s)
      s.mobile = elem.width() < 768
      s.screenWidth = if s.mobile then 'mobile' else 'web'
      s.padding = [35, 25, 15, 25]
      s.centerPoint = { zoom: 3, lat: 1, lng: 1 }
      s.maxBounds = [[-84,-400], [84,315]]

      s.events = { map: { enable: ['moveend', 'click'], logic: 'emit' } } # Handle map events using Angular-Leaflet event logic
      
      s.defaults = 
        minZoom: 2
        maxZoom: 18
        scrollWheelZoom: false
        doubleClickZoom: true
        zoomControlPosition: 'topright'
        layersControl: false

      s.bounds = leafletBoundsHelpers.createBoundsFromArray [[-84,-400], [84,315]]

      s.layers = 
        baselayers: 
          xyz:
            name: 'MapQuest'
            url: 'http://otile1.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg'
            type: 'xyz'
            attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
        overlays: 
          primary:
            name: "Primary Places"
            type: "markercluster"
            visible: true
            layerOptions:
              chunkedLoading: true #?look at
              showCoverageOnHover: true
              removeOutsideVisibleBounds: true
              polygonOptions: { color: "#ff0066", opacity: 1.0, fillColor: "#ff0066", fillOpacity: 0.4, weight: 3  }
              maxClusterRadius: 50
              spiderifyDistanceMultiplier: 2
              requireDoubleClick: s.mobile
              paddingToFocusArea: s.padding
              iconCreateFunction: (cluster) -> s.marker.clusterPin(cluster)

      s.placesInView = s.clustersInView = []

      s._getPlaces = (userId, currentUserId) ->
        s._getPrimaryPlaces(userId).then ->
          if currentUserId && currentUserId != userId
            s._getContextPlaces(currentUserId).then( s._definePlaces() )
          else
            s._definePlaces()

      s._getPlacesAndClustersInView = ->
        return unless s.places
        s._filterPlaces()
        leafletData.getMap().then (m) ->
          [s.map, s.bounds] = [ m, m.getBounds() ]
          [s.sw, s.ne] = [s.bounds._southWest, s.bounds._northEast]
          s._updateQuery()
          $timeout ( -> s._getClustersInView( s._getPlacesInView  ) ) , 400

      s._getPlacesInView = (callback) ->
        s.placesInView = _(s.places).filter( (p) -> 
          s._inBounds(p) && !_(s.clustersInView).some( (c) => _(c.places).map('id').includes(p.id) ) 
        ).value()

        callback?()

      s._getClustersInView = (callback) ->
        return unless s.places
        leafletData.getLayers().then (layers) ->
          s.markerClusterGroup = layers.overlays.primary._featureGroup._layers
          clusters = _(s.markerClusterGroup).filter( (l) -> l._childCount > 1 && s.bounds.contains( l._bounds ) ).value()
          s.clustersInView = _(clusters).map( (c) -> s._clusterObj(c) ).value()

          callback?()

      s._inBounds = (o) ->
        F.within([s.sw.lat, s.ne.lat], o.lat) && F.within([s.sw.lng, s.ne.lng], o.lon)
        
      s._definePlaces = ->
        s.allPlaces = s.primaryPlaces.concat( if s.contextPlaces then s.contextPlaces else [] )
        s._filterPlaces()
        s.recalculateInView(false) # Don't reset cluster events, cause we're about to set all events
        s._setMouseEvents()
        s.loadedData = true # Hide the spinner from now on

      s._updateQuery = ->
        [latLon, zoom] = [s.map.getCenter(), s.map.getZoom()]
        QueryString.modify( m: "#{ latLon.lat.toFixed(4) },#{ latLon.lng.toFixed(4) },#{ zoom }" )

      s._filterPlaces = -> s.places = new PlaceFilterer( QueryString.get() ).returnFiltered( s.allPlaces )

      s._getPrimaryPlaces = (userId) ->
        User.findPlaces( userId )
          .success (places) ->
            places = Place.generateFromJSON(places.user_pins)
            s.primaryPlaces = _(places).map( (p) -> s.marker.primaryPin(p) ).value()
          .error (response) ->
            console.log response

      s._getContextPlaces = (currentUserId) ->
        User.findPlaces( currentUserId )
          .success (places) ->
            places = Place.generateFromJSON( places.current_user_pins )
            s.contextPlaces = _(places).map( (p) -> s.marker.contextPin(p) ).value()
          .error (response) ->
            console.log response

      s._clusterOn = (eventType, methodToFire) ->
        return s.markerClusterGroup.on(eventType, methodToFire) if s.markerClusterGroup
        s.setLayers( -> s.markerClusterGroup.on( eventType, methodToFire ) )

      s.recalculateInView = (setClusterEvents = true) -> 
        s._getPlacesAndClustersInView()
        new BucketEventManager(s).resetClusterEvents() if setClusterEvents

      s._setMouseEvents = -> new BucketEventManager(s).waitAndSetMouseEvents()

      s.isSelectedPlace = (place) -> s.selectedPlaceId == place.id

      s._markerForPlaceId = (id) -> $(".default-map-icon-tab\#p#{id}")

      s._markerForClusterId = (id) -> $(".cluster-map-icon-tab\##{id}")

      s._clusterObj = (c) ->
        places = _( c.getAllChildMarkers() ).map('options').value()
        { id: "c#{c._leaflet_id}", count: c._childCount, center: c._latlng, places: places, location: s._bestListLocation(places, c._latlng), clusterObject: c }

      s._bestListLocation = (places, center) ->
        location = BasicOperators.commaAndJoin( _(places).map('names').map((p) -> p[0]).value() ) if places.length < 3
        location ||= Place.lowestCommonArea(places)
        location ||= ClusterLocator.nearestGlobalRegion(center)
        return location
      
      s.$on '$locationChangeSuccess', (event, next) -> 
        s._filterPlaces()
        s._getPlacesAndClustersInView()

      # INIT
      s._getPlaces(s.userId, s.currentUserId)
  }