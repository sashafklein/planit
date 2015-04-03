angular.module("Common").directive 'sidebarMap', () ->
  return {
    restrict: 'E'
    transclude: true
    # replace: true
    templateUrl: 'sidebar_map.html'
    scope: 
      webPadding: '@'
      zoomControl: '@'
      unwrappedPlaces: '='
      showPlacesFilter: '@'
    link: (s, e, a) ->
      s.unwrappedPlaces = []
      s.centerPoint = { lat: 1, lng: 1, zoom: 2 }
      s.zoomControl = if s.zoomControl then s.zoomControl else 'topright'
      s.webPadding = s.mobilePadding = null
      s.showPlacesFilter = if s.showPlacesFilter then true else false
  }