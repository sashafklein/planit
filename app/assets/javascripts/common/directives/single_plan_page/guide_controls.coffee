angular.module("Common").directive 'guideControls', ($timeout, Plan, ErrorReporter) ->
  {
    restrict: 'E'
    replace: true
    templateUrl: 'single/plan_box/_guide_controls.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.saveRenamePlan = -> s.m.plans[s.m.currentPlanId].rename( s.m.rename, s.cancelRenamePlan() )

      s.renamePlan = ->
        if s.m.plans[s.m.currentPlanId].userOwns()
          s.m.rename = s.m.plans[s.m.currentPlanId]?.name || ' '
          $timeout(-> $('#rename').focus() if $('#rename') )
          return
          
      s.cancelRenamePlan = -> s.m.rename = null

  }