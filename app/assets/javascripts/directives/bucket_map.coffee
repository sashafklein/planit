angular.module("Directives").directive 'bucketMap', (Place, User, PlanitMarker, leafletData, BasicOperators, ClusterLocator, BucketEventManager, $timeout, QueryString, PlaceFilterer, CurrentUser, ErrorReporter) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'bucket_map.html'
    scope:
      userId: '@'
      zoomControl: '='
      webPadding: '@'
      mobilePadding: '@'

    link: (s, elem) ->
      $('.loading-mask.content-only').show()
      s.loaded = false
      s.currentUserId = CurrentUser.id
      s.marker = new PlanitMarker(s)
      s.mobile = elem.width() < 768
      s.web = !s.mobile
      s.screenWidth = if s.mobile then 'mobile' else 'web'
      s.padding = [35, 25, 15, 25]
      s.padding = JSON.parse("[" + s.mobilePadding + "]") if s.mobilePadding && s.mobile
      s.padding = JSON.parse("[" + s.webPadding + "]") if s.webPadding && s.web
      s.changes = 0
      s.maxBounds = [[-84,-400], [84,315]]
      s.centerAndZoom = QueryString.get()['m'] || null
      s.centerPoint = if s.centerAndZoom then { lat: parseFloat( s.centerAndZoom.split(',')[0] ), lng: parseFloat( s.centerAndZoom.split(',')[1] ), zoom: parseFloat( s.centerAndZoom.split(',')[2] ) } else { lat: 0, lng: 0, zoom: 2 }
      s.placesInView = s.clustersInView = []
      s.leaf = leafletData

      s.defaults = 
        minZoom: if s.mobile then 1 else 2
        maxZoom: 18
        scrollWheelZoom: false
        doubleClickZoom: true
        zoomControl: if ( s.zoomControl && s.web ) then true else false
        zoomControlPosition: 'topright'

      s.layers = 
        baselayers: 
          xyz:
            name: 'MapQuest'
            url: "https://otile#{ Math.floor(Math.random() * (4 - 1 + 1)) + 1 }-s.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg"
            type: 'xyz'
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
              maxClusterRadius: 60
              disableClusteringAtZoom: 13
              spiderifyDistanceMultiplier: 2
              requireDoubleClick: s.mobile
              paddingToFocusArea: s.padding
              iconCreateFunction: (cluster) -> 
                initial = 0
                s.marker.clusterPin(cluster, initial)

      s._getPlaces = (userId, currentUserId) ->
        s._getPrimaryPlaces(userId).then ->
          if currentUserId && currentUserId != userId
            s._getContextPlaces(currentUserId).then( s._definePlaces() )
          else
            s._definePlaces()

      # ON MAP MOVEMENT

      s.recalculateInView = -> 
        return unless s.places
        s.changes++
        $timeout ( -> 
          s._setCurrentLayers( s._setItemsInView )
          s._setCurrentMap( s._updateQuery )
        ), 400

      s._setCurrentLayers = (callback) ->
        leafletData.getLayers().then (l) ->
          s.currentLayers = l.overlays.primary._featureGroup._layers
          callback?()

      s._setItemsInView = ->
        return unless s.currentLayers
        leafletData.getMap().then (m) ->
          s.currentBounds = m.getBounds()
          s.clustersInView = _(s.currentLayers)
            .filter( (l) -> l._childCount > 1 && s.currentBounds.contains( l._bounds ) )
            .map( (c) -> s._clusterObj c )
            .sortBy( (c) -> -1*c.count )
            .value()
          s.placesInView = _(s.currentLayers)
            .filter( (l) -> l.options.id && s.currentBounds.contains( l._latlng ) )
            .map( (p) -> p.options )
            .value()

      s._setCurrentMap = (callback) ->
        leafletData.getMap().then (m) ->
          s.currentLLZoom = { lat: m.getCenter().lat, lon: m.getCenter().lng, zoom: m.getZoom() }
          callback?()

      s._updateQuery = ->
        if s.loaded && s.currentLLZoom
          QueryString.modify( m: "#{ s.currentLLZoom.lat.toFixed(4) },#{ s.currentLLZoom.lon.toFixed(4) },#{ s.currentLLZoom.zoom }" )

      # SET MAP DATA

      s._definePlaces = ->
        s.allPlaces = s.primaryPlaces.concat( if s.contextPlaces then s.contextPlaces else [] )
        s._filterPlaces( s.recalculateInView )
        s._initiateCenterAndBounds()

      s._initiateCenterAndBounds = ->
        if !s.centerAndZoom
          startLats = _.map( s.places, (p) -> p.lat )
          startLons = _.map( s.places, (p) -> p.lon )
          leafletData.getMap().then (m) ->
            m.fitBounds( 
              L.latLngBounds( L.latLng(_.min(startLats),_.min(startLons)),L.latLng(_.max(startLats),_.max(startLons)) ),
              { paddingTopLeft: [s.padding[3], s.padding[0]], paddingBottomRight: [s.padding[1], s.padding[2]] }
            )
        $('.loading-mask.content-only').hide()
        $timeout (-> 
          s.loaded = true
          s._disableMapManipulationOnInfoBox()
          s._adjustInfoBoxSize()
          ), 2000

      s._filterPlaces = (callback) -> 
        s.places = new PlaceFilterer( QueryString.get() ).returnFiltered( s.allPlaces )
        $timeout(-> callback?() )

      s._getPrimaryPlaces = (userId) ->
        User.findPlaces( userId )
          .success (places) ->
            places = Place.generateFromJSON(places.user_pins)
            s.primaryPlaces = _(places).map( (p) -> s.marker.primaryPin(p) ).value()
          .error (response) ->
            ErrorReporter.report({ userId: userId })

      s._getContextPlaces = (currentUserId) ->
        User.findPlaces( currentUserId )
          .success (places) ->
            places = Place.generateFromJSON( places.current_user_pins )
            s.contextPlaces = _(places).map( (p) -> s.marker.contextPin(p) ).value()
          .error (response) ->
            ErrorReporter.report({ userId: userId })

      s.clusterFromId = (id) ->
        _.filter( s.clustersInView , (c) -> c.id == id )[0]

      s.placeFromId = (id) ->
        _.filter( s.placesInView , (p) -> 'p' + p.id == id )[0]

      s._clusterObj = (c) ->
        places = _( c.getAllChildMarkers() ).map('options').value()
        { id: "c#{c._leaflet_id}", count: c._childCount, center: c._latlng, bounds: c._bounds, places: places, location: s._bestListLocation(places, c._latlng), clusterObject: c }

      s._bestListLocation = (places, center) ->
        location = BasicOperators.commaAndJoin( _(places).map('names').map((p) -> p[0]).value() ) if places.length < 3
        location ||= Place.lowestCommonArea(places)
        location ||= ClusterLocator.nearestGlobalRegion(center)
        return location
      
      s.mouse = (type, id) -> new BucketEventManager(s).mouseEvent( type, id )

      # Gives jQuery access to map events
      window.mapMouseEvent = s.mouse

      s.zoomToCluster = (cluster) ->
        leafletData.getMap().then (m) ->
          m.fitBounds( cluster.bounds , { paddingTopLeft: [s.padding[3], s.padding[0]], paddingBottomRight: [s.padding[1], s.padding[2]] } )
          new BucketEventManager(s).deselectAll()

      s.$on 'leafletDirectiveMap.moveend', -> s.recalculateInView() if s.web

      s.$on '$locationChangeSuccess', (event, next) -> s._filterPlaces( s.recalculateInView ) if s.allPlaces?.length

      s._adjustInfoBoxSize = ->
        $('#in-view-list').css('max-height', ( parseInt( $('.bucket-map-canvas').height() * 0.9 ) - parseInt( $('.filter-dropdown-toggle').height() ) ).toString() + 'px') if s.web

      s._disableMapManipulationOnInfoBox = ->
        if infoBox = document.getElementById('map-info-box')
          leafletData.getMap().then (m) ->
            infoBox.addEventListener 'mouseover', -> m.dragging.disable() ; m.doubleClickZoom.disable()
            infoBox.addEventListener 'mouseout', -> m.dragging.enable() ; m.doubleClickZoom.disable()


      # FILTERING

      s.filters = {}
      s.filtering = false
      s.toggleFilter = -> s.filtering = !s.filtering

      s._filterString = -> 
        vals = _(s.filters).map( (v,k) -> if v then k else null ).compact().value()
        if vals.length then vals.join(",") else null

      s._initFilters = ->
        filters = _.compact QueryString.get()['f']?.split(",")
        defaultTrue = _.compact( _.map s.filterList, (i) -> return i['slug'] if i['def'] == true )
        _.forEach( filters, (k) => s.filters[k] = !( _.filter( s.filterList, (f) -> f['slug'] == k )['def'] ) )
        _.forEach( defaultTrue, (k) -> s.filters[k] = true ) if !( _.filter( filters, (k) -> _.contains(defaultTrue, k) )[0] )

      # s.filtersSet = -> _.some(s.filters, (v) -> v )

      s.filterList = [
        { header: "Type of Place" }
        { slug: 'food', def: true, name: 'Food/Markets', icon: 'md-local-restaurant' }
        { slug: 'drink', def: true, name: 'Drink/Nightlife', icon: 'md-local-bar' }
        { slug: 'seedo', def: true, name: 'See/Do', icon: 'md-directions-walk' }
        { slug: 'stay', def: true, name: 'Stay', icon: 'md-home' }
        { slug: 'relax', def: true, name: 'Relax', icon: 'md-drink' }
        { slug: 'other', def: true, name: 'Other', icon: 'fa fa-question-circle' }
        # { divider: true }
        # { header: "Specifics" }
        # { slug: 'open', def: false, name: 'Open', only: true, icon: 'fa fa-clock-o' }
        # { slug: 'wifi', def: false, name: 'Wifi', only: true, icon: 'fa fa-wifi' }
        # { slug: 'loved', def: false, name: 'Most Loved', only: true, icon: "fa fa-heart" }
        # { slug: 'been', def: false, name: "Haven't Been To Yet", only: true, icon: "fa fa-check-square" }
      ]

      s.clearFilters = () -> s.filters = {}
      
      # FILTER INIT
      s._initFilters()
      s.$watch('filters', (-> QueryString.modify( f: s._filterString() ) ), true ) # On filter change, update the QueryString

      window.bm = s

      # MAPWIDE INIT
      s._getPlaces(s.userId, s.currentUserId)
  }