angular.module("Common").directive 'planSettings', (Flash, ErrorReporter, Spinner) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_plan_settings.html'
    scope:
      m: '='
    link: (s, e, a) ->
      s.kmlPath = -> "/api/v1//#{ s.m.currentPlanId }/kml" unless !s.m.currentPlanId?
      s.printPath = -> "/plans/#{ s.m.currentPlanId }/print" unless !s.m.currentPlanId?

  }