angular.module("Directives").directive 'savePlacesOnClick', (Mark, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'
    scope:
      successFunction: '&'

    link: (scope, element, attrs) ->
      
      element.bind "click", (event) ->
        # place_ids = scope.$eval attrs.savePlacesOnClick 
        # Mark.create({ place_id: place_id })
        #   .success (response) ->
        #     if scope.successFunction? then scope.successFunction() else true
        #   .error (response) ->
        #     ErrorReporter.loud("savePlacesOnClick Mark.create", response, { place_id: place_id, user_id: CurrentUser.id })
  }