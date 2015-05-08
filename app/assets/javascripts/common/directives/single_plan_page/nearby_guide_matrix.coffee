angular.module("Common").directive 'nearbyGuideMatrix', (ClassFromString) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_nearby_guide_matrix.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.exitBrowse = -> s.m.browsing=false

  }