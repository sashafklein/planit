angular.module("Directives").directive 'beenPlaceOnClick', (Mark, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'
    scope:
      successFunction: '&'

    link: (scope, element, attrs) ->
      
      element.bind "click", (event) ->
        place_id = scope.$eval attrs.beenPlaceOnClick
        $('.loading-mask').show()
        Mark.been( place_id )
          .success (response) ->
            if scope.successFunction? then scope.successFunction() else true
            $('.loading-mask').hide()
          .error (response) ->
            ErrorReporter.silent( response, 'beenPlaceOnClick', { place_id: place_id })
            $('.loading-mask').hide()
  }