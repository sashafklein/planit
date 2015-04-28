angular.module("Common").directive 'guideControls', ($timeout, Plan, ErrorReporter) ->
  {
    restrict: 'E'
    replace: true
    templateUrl: 'single/plan_box/_guide_controls.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.saveRenameList = -> 
        s.m.list.update({ plan: { name: s.m.rename } })
          .success (response) ->
            s.m.list = Plan.generateFromJSON( response )
            s.cancelRenameList()
          .error (response) ->
            s.cancelRenameList()
            ErrorReporter.defaultFull({ context: 'Failed to rename plan', list_id: s.m.list.id})

      s.renameList = ->
        if s.m.userOwnsLoadedList
          s.m.rename = s.m.list.name || ' '
          $timeout(-> $('#rename').focus() if $('#rename') )
          return
          
      s.cancelRenameList = -> s.m.rename = null

  }