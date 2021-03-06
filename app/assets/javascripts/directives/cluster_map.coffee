angular.module("Directives").directive 'clusterMap', (Place, User, PlanitMarker, leafletData, BasicOperators, ClusterLocator, PlanEventManager, $timeout, QueryString, PlaceFilterer, CurrentUser, ErrorReporter, ClassFromString) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'cluster_map.html'
    scope:
      m: '='
      zoomControl: '='
      webPadding: '@'
      mobilePadding: '@'
      # setNearbyFromCenter: '&'

    link: (s, elem) ->

      s.defineMapCriteria = ->
        s.elem = elem
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
        s.clusterCenter = if ( s.m?.currentLocation()?.lat && !s.m?.marksInCluster()?.length>0 ) then { lat: s.m.currentLocation().lat, lng: s.m.currentLocation().lon, zoom: 12 } else { lat: 0, lng: 0, zoom: 2 }
        s.placesInView = s.clustersInView = s.firstPlaces = []
        s.leaf = leafletData

        s.clusterDefaults = 
          minZoom: if s.mobile then 1 else 3
          maxZoom: 18
          scrollWheelZoom: false
          doubleClickZoom: true
          zoomControl: if ( s.zoomControl && s.web ) then true else false
          zoomControlPosition: 'topright'

        s.clusterLayers = 
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

      s._getPlaces = ->
        s._setOnScope [ 'firstPlaces', 'places', 'preFilterPlaces' ], []
        $timeout(-> s.firstPlaces = _.extend( [], s.m?.marksInCluster() ) )
        $timeout(-> s.preFilterPlaces = _.map( s.m?.marksInCluster(), (p) -> s.marker.primaryPin(p) ) )
        $timeout(-> s._definePlaces() )
        leafletData.getMap("cluster").then (map) -> $timeout( (-> map.invalidateSize() ), 200)

      # ON MAP MOVEMENT

      s.recalculateInView = -> 
        return unless s.places
        s.changes++
        $timeout ( -> 
          s._setCurrentLayers( s._setItemsInView )
          s._setCurrentMap( s._updateQuery )
        ), 400

      s._setCurrentLayers = (callback) ->
        leafletData.getLayers("cluster").then (l) ->
          s.currentLayers = l.overlays?.primary?._featureGroup?._layers
          callback?()

      s._setItemsInView = ->
        return unless s.currentLayers
        leafletData.getMap("cluster").then (m) ->
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
        leafletData.getMap("cluster").then (m) ->
          s.currentLLZoom = { lat: m.getCenter().lat, lon: m.getCenter().lng, zoom: m.getZoom() }
          callback?()

      s._updateQuery = -> null
        # if s.loaded && s.currentLLZoom && s.m?.mode=='map'
        #   # QueryString.modify( m: "#{ s.currentLLZoom.lat.toFixed(4) },#{ s.currentLLZoom.lon.toFixed(4) },#{ s.currentLLZoom.zoom }" )
        #   # s.setNearbyFromCenter({center:"#{ s.currentLLZoom.lat.toFixed(4) },#{ s.currentLLZoom.lon.toFixed(4) }"})

      # SET MAP DATA

      s._definePlaces = ->
        s.places = _.extend( [], s.preFilterPlaces ) # unless s.changedItems
        leafletData.getLayers("cluster").then (l) ->
          s.leafletLayers = l
        s._filterPlaces( s.recalculateInView )
        $timeout( (-> s._initiateCenterAndBounds() ), 200)
        $timeout( (-> s.clusterInitialized = true ), 200)

      s.fitBoundsOnFilteredPlaces = ->
        startLats = _.map( s.places, (p) -> p.lat )
        startLons = _.map( s.places, (p) -> p.lon )
        return unless startLats?.length>0 && startLons?.length>0
        leafletData.getMap("cluster").then (m) ->
          m.fitBounds( 
            L.latLngBounds( L.latLng(_.min(startLats),_.min(startLons)),L.latLng(_.max(startLats),_.max(startLons)) ),
            { paddingTopLeft: [s.padding[3], s.padding[0]], paddingBottomRight: [s.padding[1], s.padding[2]] }
          )

      s._initiateCenterAndBounds = ->
        s.fitBoundsOnFilteredPlaces() # if !s.centerAndZoom
        $('.loading-mask.content-only').hide()
        $timeout (-> 
          s.loaded = true
          s._disableMapManipulationOnInfoBox()
          s._adjustInfoBoxSize()
          ), 2000

      s._filterPlaces = (callback) -> 
        # s.places = new PlaceFilterer( QueryString.get() ).returnFiltered( s.preFilterPlaces )
        $timeout(-> callback?() )

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
      
      s.mouse = (type, id) -> new PlanEventManager(s).mouseEvent( type, id )

      # Gives jQuery access to map events
      window.mapMouseEvent = s.mouse

      s.zoomToCluster = (cluster) ->
        return unless cluster?.bounds
        leafletData.getMap("cluster").then (m) ->
          m.fitBounds( cluster.bounds , { paddingTopLeft: [s.padding[3], s.padding[0]], paddingBottomRight: [s.padding[1], s.padding[2]] } )
          new PlanEventManager(s).deselectAll()

      s.$on 'leafletDirectiveMap.moveend', -> s.recalculateInView() if s.web && s.m?.marksInCluster()?.length

      s.$on '$locationChangeSuccess', (event, next) -> s._filterPlaces( s.recalculateInView ) if s.m?.marksInCluster()?.length

      s._adjustInfoBoxSize = ->
        $('#in-view-list').css('max-height', ( parseInt( $('.plan-map-canvas').height() * 0.9 ) - parseInt( $('.filter-dropdown-toggle').height() ) ).toString() + 'px') if s.web

      s._disableMapManipulationOnInfoBox = ->
        if infoBox = document.getElementById('map-info-box')
          leafletData.getMap("cluster").then (m) ->
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

      s.filtersSet = -> _.some(s.filters, (v) -> v )

      s.filterList = [
        { header: "Type of Place" }
        { slug: 'food', def: true, name: 'Food/Markets', icon: 'md-local-restaurant' }
        { slug: 'drink', def: true, name: 'Drink/Nightlife', icon: 'md-local-bar' }
        { slug: 'seedo', def: true, name: 'See/Do', icon: 'md-directions-walk' }
        { slug: 'stay', def: true, name: 'Stay', icon: 'md-home' }
        { slug: 'relax', def: true, name: 'Relax', icon: 'md-local-bar' }
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
      s.$watch('filters', (-> QueryString.modify( f: s._filterString() ) if s.clusterInitialized && s.m?.mode=='map' ), true ) # On filter change, update the QueryString

      # MAPWIDE INIT
      s.clusterInitialized = false
      s.initialize = ->
        if !s.clusterInitialized && s.m?.mode=='map' # && s.m?.marksInCluster()?.length
          $('.loading-mask.content-only').show()
          s.clusterCenter = if ( s.m.currentLocation()?.lat && !s.m.marksInCluster()?.length>0 ) then { lat: s.m.currentLocation().lat, lng: s.m.currentLocation().lon, zoom: 12 } else { lat: 0, lng: 0, zoom: 2 }
          $timeout(-> s.defineMapCriteria() )
          $timeout(-> s._getPlaces() )
        else if s.clusterInitialized && s.m?.mode=='map'
          return if _.isEqual( s.m?.marksInCluster(), s.firstPlaces ) && s.m?.marksInCluster().length != 0
          s.changedItems = true
          s.clusterCenter = if ( s.m.currentLocation()?.lat && !s.m.marksInCluster()?.length>0 ) then { lat: s.m.currentLocation().lat, lng: s.m.currentLocation().lon, zoom: 12 } else { lat: 0, lng: 0, zoom: 2 }
          $timeout(-> s.defineMapCriteria() )
          $timeout(-> s._getPlaces() )
        else if s.clusterInitialized && !s.m?.mode=='map'
          s.resetMapContent()

      s.resetMapContent = ->
        s._setOnScope [ 'firstPlaces', 'places', 'preFilterPlaces', 'placesInView', 'clustersInView' ], []
        s._setOnScope [ 'currentLLZoom', 'currentBounds', 'centerAndZoom' ], null
        s.clusterInitialized = false
        s.center = { lat: 0, lng: 0, zoom: 2 }
        s.filters = {}
        QueryString.modify({f: null, m: null})

      s.marksInCluster = -> s.m?.marksInCluster()

      s.$watch('marksInCluster()', (-> s.initialize() ), true )
      s.$watch('m.mode', (-> s.initialize() ), true )

      s._setOnScope = (list, value = null) -> _.forEach list, (i) -> s[i] = ( if value? then _.clone(value) else null )

      s.placeClass = (p, index) -> "p#{p.id} #{ClassFromString.toClass(p.name, index)}"

      window.cm = s
  }