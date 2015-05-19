angular.module("Directives").directive 'baseMap', (Place, PlanitMarker, leafletData, MapEventManager, $timeout) ->

  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: '''
      <div class='base-map-div' style='width:100%; height:100%'>
        <div class='leaflet-wrapper' ng-if='layers' ng-show='centerSet'>
          <ng-transclude class='base-map-transclude'></ng-transclude>
          <leaflet markers='places' defaults='defaults' height='100%' width='100%' center='centerPoint' layers='layers'></leaflet>
        </div>
      </div>
    '''
    scope:
      webPadding: '=?'
      mobilePadding: '=?'
      zoomControl: '=?'
      unwrappedPlaces: '='
      centerPoint: '=?'
      eventManager: '=?'
      popups: '=?'

    link: (s, elem) ->
      s.eventManager = if s.eventManager then s.eventManager else MapEventManager
      s.places = []
      s.zoomControl = 'topright'
      s.marker = new PlanitMarker(s)
      s.mobile = $(document).width() < 768
      s.web = !s.mobile
      s.screenWidth = if s.mobile then 'mobile' else 'web'
      s.padding = [35, 25, 15, 25]
      s.padding = JSON.parse("[" + s.mobilePadding + "]") if s.mobilePadding && s.mobile
      s.padding = JSON.parse("[" + s.webPadding + "]") if s.webPadding && s.web
      s.centerPoint ||= { lat: 0, lng: 0, zoom: 2 }
      $timeout( ( -> s.centerSet = true), 500 )
      
      s.leaf = leafletData

      s.defaults = 
        minZoom: if s.mobile then 1 else 2
        maxZoom: 18
        scrollWheelZoom: false
        doubleClickZoom: true
        zoomControl: if ( s.zoomControl && s.web ) then true else false
        zoomControlPosition: s.zoomControl

      s.layers = 
        baselayers:
          mq:
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
              iconCreateFunction: (cluster) -> 
                s.marker.clusterPin(cluster, 0)

      s.mouse = (type, id) -> new s.eventManager(s).mouseEvent( type, id )
      
      s.$watch 'unwrappedPlaces', ->
        if s.unwrappedPlaces?.length && !s.places?.length
          s.places = _.map( 
            Place.generateFromJSON(s.unwrappedPlaces), 
            (p) -> (if s.popup then s.marker.primaryPin(p, true) else s.marker.primaryPin(p))
          )
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

      window.bm = s
      window.mapMouseEvent = s.mouse
  }