angular.module("Common").directive 'beenPlaceOnClick', (Mark, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'
    scope:
      successFunction: '&'

    link: (scope, element, attrs) ->
      
      element.bind "click", (event) ->
        place_id = scope.$eval attrs.beenPlaceOnClick 
        Mark.been( place_id )
          .success (response) ->
            if scope.successFunction? then scope.successFunction() else true
          .error (response) ->
            ErrorReporter.report({ place_id: place_id, user_id: CurrentUser.id, context: "Inside beenPlaceOnClick directive" })
  }