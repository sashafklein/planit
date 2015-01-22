angular.module("Common").directive 'placesMap', (MapOptions, F, API, Place) ->
  return {
    restrict: 'E'
    transclude: true
    replace: true
    template: "<div class='ng-map-div'><div ng_transclude=true></div></div>"
    scope:
      placeIds: '@'

    link: (scope, element) ->
      scope.placeIds = JSON.parse(scope.placeIds)
      Place.where({ id: scope.placeIds })
        .success (places) ->
          scope.places = Place.generateFromJSON(places)
          scope.drawMap()
        .error (response) ->
          alert("Failed to grab places information!")
          console.log response

      scope.drawMap = () ->
        window.places = scope.places

  }