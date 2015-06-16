angular.module("Directives").directive 'itemActionsBar', (Mark, Modal, CurrentUser, ErrorReporter) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "item_actions_bar.html"
    scope:
      m: '='
      item: '='
      placeRaw: '='

    link: (s, element) ->

      s.place = _.find( s.m.marksInCluster(), (p) -> parseInt(p.id) == parseInt(s.placeRaw.id) ) if s.m?.marksInCluster() && s.placeRaw?.id

  }