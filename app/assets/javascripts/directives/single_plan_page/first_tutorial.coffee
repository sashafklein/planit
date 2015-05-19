angular.module("Directives").directive 'firstTutorial', () ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_first_tutorial.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.hasPlaceNameOptions = -> s.m.placeNameOptions?.length > 0
      s.hasPlaceNearbyOptions = -> s.m.placeNearbyOptions?.length > 0
  }