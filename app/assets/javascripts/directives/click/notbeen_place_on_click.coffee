angular.module("Directives").directive 'notbeenPlaceOnClick', (Mark, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'
    scope:
      successFunction: '&'

    link: (scope, element, attrs) ->
      
      element.bind "click", (event) ->
        place_id = scope.$eval attrs.notbeenPlaceOnClick 
        $('.loading-mask').show()
        Mark.notbeen( place_id )
          .success (response) ->
            if scope.successFunction? then scope.successFunction() else true
            $('.loading-mask').hide()
          .error (response) ->
            ErrorReporter.loud("notbeenPlaceOnClick Mark.notBeen", response, { place_id: place_id, user_id: CurrentUser.id })
            $('.loading-mask').hide()
  }