angular.module('Common').directive 'sortCommands', (QueryString) ->
  return { 
    restrict: 'E'
    replace: 'true'
    templateUrl: 'single/_sort_commands.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.setMode = ( mode ) -> QueryString.modify({ mode: mode })
  
  }