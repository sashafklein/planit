angular.module("Common").directive 'planSettings', () ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_plan_settings.html'
    scope:
      m: '='
    link: (s, e, a) ->
  }