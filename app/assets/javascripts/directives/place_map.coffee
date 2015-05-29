angular.module("Directives").directive 'placeMap', (Place, ErrorReporter) ->

  return {
    restrict: 'E'
    transclude: true
    template: "<no-sidebar-map unwrapped-places='places' ng-show='loaded' ></no-sidebar-map>"
    scope:
      placeId: '@'

    link: (s, element) ->

      Place.find( s.placeId )
        .success (place) ->
          s.places = [ place ]
          s.centerPoint = { lat: place.lat, lng: place.lon, zoom: 17 }
          s.loaded = true
        .error (response) ->
          ErrorReporter.loud("placeMap Place.find", response, { place_id: s.placeId }, "The map failed to load! We've been notified")
  }