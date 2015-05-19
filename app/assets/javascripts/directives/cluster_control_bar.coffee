angular.module("Directives").directive 'clusterControlBar', (Mark, Modal, CurrentUser, ErrorReporter) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "cluster_control_bar.html"
    scope:
      places: '='

    link: (s, element) ->

      s.userId = CurrentUser.id

      s.initialCalcs = -> 
        s.hasTheseMarks = _.filter( s.places, (p) -> _.include( p.savers, s.userId ) )
        s.doesntHaveTheseMarks = _.filter( s.places, (p) -> !_.include( p.savers, s.userId ) )
        s.howManyMarks = s.hasTheseMarks.length

      s.savePlaceIds = -> _.map( s.doesntHaveTheseMarks, (p) -> p.id )
      s.removePlaceIds = -> _.map( s.hasTheseMarks, (p) -> p.id )

      s.hasNoMarks = -> s.howManyMarks == 0
      s.hasAllMarks = -> s.howManyMarks == s.places.length
      s.savedPlaces = -> _.map( s.places, (p) -> p.savers.push( s.userId ) )
      s.removedPlaces = -> _.map( s.places, (p) -> p.savers.splice( s.place.savers.indexOf( s.userId ), 1 ) )

      s.initialCalcs()

  }