angular.module("Directives").directive 'removePlacesOnClick', (Mark, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'
    scope:
      successFunction: '&'

    link: (scope, element, attrs) ->
      
      element.bind "click", (event) ->
        # place_ids = scope.$eval attrs.removePlacesOnClick 
        # Mark.remove( place_id )
        #   .success (response) ->
        #     if scope.successFunction? then scope.successFunction() else true
        #   .error (response) ->
        #     ErrorReporter.report({ place_id: place_id, user_id: CurrentUser.id, context: "Inside removePlacesOnClick directive" })
  }