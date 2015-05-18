angular.module("Common").directive 'itemActionsBar', (Mark, Modal, CurrentUser, ErrorReporter) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "item_actions_bar.html"
    scope:
      m: '='
      item: '='

    link: (s, element) ->

  }