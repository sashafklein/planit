angular.module("Common").directive 'placeControlBar', (Mark, Modal, CurrentUser, ErrorReporter) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "place_control_bar.html"
    scope:
      place: '='

    link: (s, element) ->

      s.userId = CurrentUser.id

      s.hasMarkFor = -> _.include( s.place.savers, s.userId )
      s.savedPlace = -> s.place.savers.push( s.userId )
      s.removedPlace = -> s.place.savers.splice( s.place.savers.indexOf( s.userId ), 1 )

      s.loves = -> _.include( s.place.lovers, s.userId )
      s.lovedPlace = -> s.place.lovers.push( s.userId )
      s.unlovedPlace = -> s.place.lovers.splice( s.place.lovers.indexOf( s.userId ), 1 )

      s.hasBeen = -> _.include( s.place.visitors, s.userId )
      s.beenPlace = -> s.place.visitors.push( s.userId )
      s.notbeenPlace = -> s.place.visitors.splice( s.place.visitors.indexOf( s.userId ), 1 )

  }