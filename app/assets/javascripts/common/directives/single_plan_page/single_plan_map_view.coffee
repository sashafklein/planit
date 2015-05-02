angular.module("Common").directive 'singlePlanMapView', () ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/tabs/_plan_map_view.html'
    scope:
      m: '='
    link: (s, e, a) ->

      # s.nearbyFromMapCenter( center ) -> console.log "setting nearby from center"
  }