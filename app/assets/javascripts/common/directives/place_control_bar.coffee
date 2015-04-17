angular.module("Common").directive 'placeControlBar', (Mark, Modal, CurrentUser, ErrorReporter) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "place_control_bar.html"
    scope:
      place: '='
      plan: '=?'

    link: (s, element) ->

      s.planId = s.plan?.id
      s.userOwnsPlan = if s.plan?.user_id == CurrentUser.id then true else false
      s.userId = CurrentUser.id
      s.markId = s.place.mark?.id

      s.hasMarkFor = -> _.include( s.place.savers, s.userId )
      s.savedPlace = -> s.place.savers.push( s.userId )
      s.removedPlace = -> s.place.savers.splice( s.place.savers.indexOf( s.userId ), 1 )

      s.loves = -> _.include( s.place.lovers, s.userId )
      s.lovedPlace = -> s.place.lovers.push( s.userId )
      s.unlovedPlace = -> s.place.lovers.splice( s.place.lovers.indexOf( s.userId ), 1 )

      s.hasBeen = -> _.include( s.place.visitors, s.userId )
      s.beenPlace = -> s.place.visitors.push( s.userId )
      s.notbeenPlace = -> s.place.visitors.splice( s.place.visitors.indexOf( s.userId ), 1 )

      s.plannedPlace = (plan_id) -> s.place.guides.push( plan_id )
      s.removedItems = -> s.plan.splice( s.plan.items ) # need to reflect on page

      s.removeItems = -> 
        if s.plan && s.plan.id
          $('.loading-mask').show()
          s.plan.destroyItems( s.place.id )
            .success (response) ->
              s.removedItems()
              $('.loading-mask').hide()
            .error (response) ->
              ErrorReporter.report({ place_id: place.id, user_id: CurrentUser.id, context: "Removing Item in Place Control Bar directive" })
              $('.loading-mask').hide()

  }