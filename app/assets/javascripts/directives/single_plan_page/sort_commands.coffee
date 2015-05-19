angular.module("Directives").directive 'sortCommands', (QueryString) ->
  return { 
    restrict: 'E'
    replace: 'true'
    templateUrl: 'single/_sort_commands.html'
    scope:
      m: '='
    link: (s, e, a) ->
      s.setMode = ( mode ) -> QueryString.modify({ mode: mode })
      s.modeButtonClass = (mode) ->
        highlighted = if s.m.mode == mode then 'highlighted' else null
        _.compact( [highlighted, "#{mode}-toggle-button"] ).join ' '
      s.showViewMode = ( mode ) -> "#{ s._capitalize(mode) }#{ if s.m.mode == mode then ' View'  else ''}"
      s._capitalize = ( word ) -> word.slice(0, 1).toUpperCase() + word.slice(1)
  
  }