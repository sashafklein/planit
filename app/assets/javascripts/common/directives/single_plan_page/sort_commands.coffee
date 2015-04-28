angular.module('Common').directive 'sortCommands', (QueryString) ->
  return { 
    restrict: 'E'
    replace: 'true'
    templateUrl: 'single/_sort_commands.html'
    scope:
      m: '='
    link: (s, e, a) ->
      s.setMode = (mode) -> 
        s.m.mode = mode
        QueryString.modify({mode: mode})
        if mode == 'map' then s.m.showMap = true else s.m.showMap = false
        # if mapCenter = QueryString.get()['m'] then @nearbyFromMapCenter( mapCenter )
  }