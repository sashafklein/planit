angular.module("Common").directive 'placeControlBar', (Mark, Modal, CurrentUser, ErrorReporter) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "place_control_bar.html"
    scope:
      place: '='
      items: '=?'
      plan: '=?'

    link: (s, element) ->

      s.planId = s.plan?.id
      s.userOwnsPlan = if s.plan?.user_id == CurrentUser.id then true else false
      s.userId = CurrentUser.id
      s.markId = s.place.mark?.id

      s.hasMarkFor = -> _.include( s.place.savers, s.userId )
      s.savedPlace = -> s.place.savers.push( s.userId )
      s.removedPlace = -> 
        s.place.savers.splice( s.place.savers.indexOf( s.userId ), 1 ) if s.place.savers.indexOf( s.userId ) != -1
        # s.removedItem()

      s.loves = -> _.include( s.place.lovers, s.userId )
      s.lovedPlace = -> s.place.lovers.push( s.userId )
      s.unlovedPlace = -> s.place.lovers.splice( s.place.lovers.indexOf( s.userId ), 1 ) if s.place.lovers.indexOf( s.userId ) != -1

      s.hasBeen = -> _.include( s.place.visitors, s.userId )
      s.beenPlace = -> s.place.visitors.push( s.userId )
      s.notbeenPlace = -> s.place.visitors.splice( s.place.visitors.indexOf( s.userId ), 1 ) if s.place.visitors.indexOf( s.userId ) != -1

      s.plannedPlace = (plan_id) -> s.place.guides.push( plan_id )
      # s.removedItem = ->
      #   if s.planId && s.userOwnsPlan && s.items
      #     s.place.guides.splice( s.place.guides.indexOf( s.planId ), 1 ) if s.place.guides.indexOf( s.planId ) != -1
      #     s.plan.place_ids.splice( s.plan.place_ids.indexOf( s.place.id ), 1 ) if s.plan.place_ids.indexOf( s.place.id ) != -1
      #     s.items.splice( s.items.indexOf( _.filter( s.items, (i) -> i.mark.place.id == s.place.id )[0] ), 1 )

  }