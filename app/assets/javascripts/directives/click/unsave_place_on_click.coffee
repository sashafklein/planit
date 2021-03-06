angular.module("Directives").directive 'unsavePlaceOnClick', (Mark, Modal, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'
    scope:
      successFunction: '&'

    link: (scope, element, attrs) ->
      
      element.bind "click", (event) ->
        place_id = scope.$eval attrs.unsavePlaceOnClick 
        $('.loading-mask').show()
        Mark.remove( place_id )
          .success (response) ->
            if scope.successFunction? then scope.successFunction() else true
            $('.loading-mask').hide()
          .error (response) ->
            ErrorReporter.loud( "unsavePlaceOnClick Mark.remove", response, { place_id: place_id, user_id: CurrentUser.id })
            $('.loading-mask').hide()
}