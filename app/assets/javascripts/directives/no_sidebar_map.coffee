angular.module("Directives").directive 'noSidebarMap', (NoSidebarMapEventManager) ->
  return {
    restrict: 'E'
    transclude: true
    # replace: true
    template: '''
      <base-map unwrapped-places='unwrappedPlaces' popups='true' zoom-control='zoomControl' web-padding='webPadding' mobile-padding='mobilePadding' center-point='centerPoint' event-manager='eventManager' height='100%'></base-map>
    '''
    scope: 
      webPadding: '=?'
      zoomControl: '=?'
      unwrappedPlaces: '='
      showPlacesFilter: '=?'
      eventManager: '=?'
    link: (s, e, a) ->
      window.sbm = s
      s.eventManager = if s.eventManager then s.eventManager else NoSidebarMapEventManager
      s.centerPoint = { lat: 1, lng: 1, zoom: 2 }
      s.zoomControl = if s.zoomControl then s.zoomControl else 'topright'
      s.webPadding = s.mobilePadding = null
      s.showPlacesFilter = if s.showPlacesFilter then true else false
  }