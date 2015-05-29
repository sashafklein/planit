angular.module("Directives").directive 'lovePlaceOnClick', (Mark, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'
    scope:
      successFunction: '&'

    link: (scope, element, attrs) ->
      
      element.bind "click", (event) ->
        place_id = scope.$eval attrs.lovePlaceOnClick 
        $('.loading-mask').show()
        Mark.love( place_id )
          .success (response) ->
            if scope.successFunction? then scope.successFunction() else true
            $('.loading-mask').hide()
          .error (response) ->
            ErrorReporter.loud("lovePlaceOnClick Mark.love", response, { place_id: place_id, user_id: CurrentUser.id })
            $('.loading-mask').hide()
  }