angular.module("Directives").directive 'nearbyGuideMatrix', (ClassFromString) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_nearby_guide_matrix.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.planImage = ( plan ) -> plan?.best_image?.url?.replace("69x69","210x210")
      s.exitBrowse = -> s.m.browsing=false

  }