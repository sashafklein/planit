angular.module("Common").directive 'singlePlanMapView', () ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/tabs/_map_view.html'
    scope:
      m: '='
    link: (s, e, a) ->
  }