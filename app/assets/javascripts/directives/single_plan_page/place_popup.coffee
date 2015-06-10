angular.module("Directives").directive 'placePopup', () ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'modals/place_popup.html'

    link: (s, e, a) ->

      s.closePopup = -> if s.canClose then s.m.placeId = null

  }