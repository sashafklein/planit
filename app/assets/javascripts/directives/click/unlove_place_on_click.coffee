angular.module("Directives").directive 'unlovePlaceOnClick', (Mark, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'
    scope:
      successFunction: '&'

    link: (scope, element, attrs) ->
      
      element.bind "click", (event) ->
        place_id = scope.$eval attrs.unlovePlaceOnClick 
        $('.loading-mask').show()
        Mark.unlove( place_id )
          .success (response) ->
            if scope.successFunction? then scope.successFunction() else true
            $('.loading-mask').hide()
          .error (response) ->
            ErrorReporter.loud("unlovePlaceOnClick Mark.unlove", response, { place_id: place_id, user_id: CurrentUser.id }, response)
            $('.loading-mask').hide()
  }