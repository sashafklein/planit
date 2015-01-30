angular.module("Common").directive 'bucketMap', (MapOptions, F, API, Place, User, PlanitMarker) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    template: """
      <div class='ng-map-div' ng-class="{'expanded': expanded()}" ng-cloak='true' >
        <div id='in-view-list'>
          <div class="bucket-list-container">
            <ul>
              <li ng-repeat='place in placesInView'>
                <div class="bucket-list-tab">
                  <div ng-if='!place.hasImage()' class="bucket-list-no-img">
                  </div>
                  <div ng-if='place.hasImage()' class="bucket-list-img" style="background-image: url('{{place.images[0].url}}');">
                  </div>
                  <div class="bucket-list-profile">
                    <a ng-href='{{place.url()}}' class="bucket-list-title">
                      {{ place.name() }} 
                    </a>
                    <div class="bucket-list-more-info">
                      <i class='fa fa-globe padding-top' ng-if=" place.meta_categories[0] == 'Area' || place.meta_categories.length == 0 "></i>
                      <span class='icon-directions-walk' ng-if=" place.meta_categories[0] == 'Do' "></span>
                      <span class='icon-local-bar' ng-if=" place.meta_categories[0] == 'Drink' "></span>
                      <span class='icon-local-restaurant' ng-if=" place.meta_categories[0] == 'Food' "></span>
                      <i class='fa fa-life-ring' ng-if=" place.meta_categories[0] == 'Help' "></i>
                      <i class='fa fa-money' ng-if=" place.meta_categories[0] == 'Money' "></i>
                      <i class='fa fa-globe' ng-if=" place.meta_categories[0] == 'Other' "></i>
                      <span class='icon-drink' ng-if=" place.meta_categories[0] == 'Relax' "></span>
                      <i class='fa fa-university xsm pad-two-top' ng-if=" place.meta_categories[0] == 'See' "></i>
                      <i class='fa fa-shopping-cart' ng-if=" place.meta_categories[0] == 'Shop' "></i>
                      <span class='icon-home' ng-if=" place.meta_categories[0] == 'Stay' "></span>
                      <i class='fa fa-exchange sm padding-bottom' ng-if=" place.meta_categories[0] == 'Transit' "></i>
                      {{ place.categories.join(', ') }}
                    </div>
                  </div>
                  <div class="bucket-list-controls">
                    <div class="bucket-list-control">
                      <div class="bucket-list-control-hint"><span>Save</span></div>
                      <span class="icomoon icon-bookmark"></span>
                    </div>    
                    <div class="bucket-list-control">
                      <div class="bucket-list-control-hint"><span>Delete</span></div>
                      <i class="fa fa-trash"></i>
                    </div>    
                    <div class="bucket-list-control">
                      <div class="bucket-list-control-hint"><span>Flag</span></div>
                      <i class="fa fa-flag"></i>
                    </div>    
                  </div>
                </div>
              </li>
            </ul>
          </div>
        </div>
      </div>
    """
    scope:
      userId: '@'
      currentUserId: '@'
      type: '@'
      zoomControl: '@'
      scrollWheelZoom: '@'
      paddingToUse: '@'
      showList: '@'

    link: (s, element) ->
      window.s = s

      s.showList = true unless s.showList

      User.findPlaces( s.userId )
        .success (places) ->
          s.primaryPlaces = Place.generateFromJSON(places.user_pins)
          s.drawMap(s, element)
        .error (response) ->
          alert("Failed to grab places information!")
          console.log response

      if s.paddingToUse then s.paddingToFocusArea = JSON.parse("[" + s.paddingToUse + "]") else s.paddingToFocusArea = [35, 25, 15, 25]

      s.expanded = -> s.$parent.mapExpanded

      s.$parent.$watch 'mapExpanded', (value) ->
        if s.map?
          currentBounds = s.map.getBounds()
          setTimeout (->
            s.map.invalidateSize()
            s.map.fitBounds(currentBounds, { paddingTopLeft: [s.paddingToFocusArea[3], s.paddingToFocusArea[0]], paddingBottomRight: [s.paddingToFocusArea[1], s.paddingToFocusArea[2]] } )
            return
          ), 400

      s.generateContextualUserPins = ->
        if s.currentUserId != s.userId
          User.findPlaces( s.currentUserId )
            .success (places) ->
              places = Place.generateFromJSON(places.current_user_pins)
              s.contextPlaces = _(places).select (place) ->
                !_( _(s.primaryPlaces).map('id') ).contains( place.id )
              for contextPlace in s.contextPlaces.value()
                PlanitMarker.contextPin(contextPlace).addTo(s.contextGroup)
            .error (response) ->
              alert("Failed to grab current user's other places!")
              console.log response

      s.drawMap = (s, elem) ->

        scrollWheelZoom = false unless s.scrollWheelZoom
        doubleClickZoom = true
        zoomControl = s.zoomControl || false
        minZoom = 1 if s.type == 'worldview'
        minZoom = 2 if s.type != 'wordlview'
        maxZoom = 18

        id = "main_map"
        elem.attr('id', id)

        s.map = L.map(id, { scrollWheelZoom: scrollWheelZoom, doubleClickZoom: doubleClickZoom, zoomControl: zoomControl, minZoom: minZoom, maxZoom: maxZoom, maxBounds: [[-86,-400],[86,315]] } )
        
        L.tileLayer('http://otile1.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpg',
          attribution: "&copy; <a href='http://www.mapquest.com/' target='_blank'>MapQuest</a>"
        ).addTo(s.map)
          
        # Create context layer and pins
        s.contextGroup = L.layerGroup()
        s.map.addLayer(s.contextGroup)
        s.generateContextualUserPins() if s.currentUserId

        # Primary Pins in Clusters if Plan, WorldView
        clusterMarkers = new L.MarkerClusterGroup({
          maxClusterRadius: 50,
          showCoverageOnHover: true,
          disableClusteringAtZoom: 18,
          spiderfyDistanceMultiplier: 2,
          polygonOptions: { color: '#ff0066', opacity: 1.0, fillColor: '#ff0066', fillOpacity: 0.4, weight: 3 },
          paddingToFocusArea: s.paddingToFocusArea,
        })
        i = 0
        s.primaryCoordinates = []
        while i < s.primaryPlaces.length
          a = s.primaryPlaces[i]
          s.primaryCoordinates.push [a.lat,a.lon]
          clusterMarker = PlanitMarker.primaryPin(a)
          clusterMarkers.addLayer clusterMarker
          i++
        s.map.addLayer(clusterMarkers)

        # Center map and inject zoom control
        s.bounds = new L.LatLngBounds(s.primaryCoordinates)
        s.map.fitBounds(s.bounds, { paddingTopLeft: [s.paddingToFocusArea[3], s.paddingToFocusArea[0]], paddingBottomRight: [s.paddingToFocusArea[1], s.paddingToFocusArea[2]] } )
        new L.Control.Zoom({ position: 'topright' }).addTo(s.map)

        # Control whether or not context pins are viewable
        s.showHideContext = () ->
          if s.map.getZoom() > 11
            s.map.addLayer(s.contextGroup)
          else
            s.map.removeLayer(s.contextGroup)
        s.showHideContext()
        s.map.on "zoomend", -> s.showHideContext()

        # Relay back viewable marker info
        s.currentBounds = -> s.map.getBounds()
        s.changePlacesInView = () ->
          s.placesInView = []
          currentBounds = s.currentBounds()
          # clusterMarkers._featureGroup._layers.eachLayer (layer) ->
          #   s.placesInView.push layer.options.placeObject if layer._childClusters._featureGroup._layers._icon && currentBounds.contains(layer._childClusters._featureGroup._layers._latlng)
          clusterMarkers.eachLayer (marker) ->
            s.placesInView.push marker.options.placeObject if currentBounds.contains(marker.getLatLng())
          if s.placesInView == [] then s.showList = false else s.showList = true
          return s.placesInView
        s.map.on "moveend", -> 
          s.$apply -> s.changePlacesInView()
        s.changePlacesInView()

  }