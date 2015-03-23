angular.module("Common").directive 'placeMap', (F, Place, User, PlanitMarker, ErrorReporter) ->

  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: "<div class='place-map'><base-map places='places' center-point='centerPoint'></base-map></div>"
    scope:
      placeId: '@'

    link: (s, element) ->

      Place.find( s.placeId )
        .success (place) ->
          s.places = [ new PlanitMarker(s).primaryPin Place.generateFromJSON(place) ]
          s.centerPoint = { lat: place.lat, lng: place.lon, zoom: 17 }
        .error (response) ->
          ErrorReporter.report({ note: "Failed to grab information for Place##{s.placeId}" })
  }