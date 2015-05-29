angular.module("Directives").directive 'savePlaceOnClick', (Mark, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'
    scope:
      successFunction: '&'

    link: (scope, element, attrs) ->
      
      element.bind "click", (event) ->
        place_id = scope.$eval attrs.savePlaceOnClick 
        $('.loading-mask').show()
        Mark.create({ place_id: place_id })
          .success (response) ->
            if scope.successFunction? then scope.successFunction() else true
            $('.loading-mask').hide()
          .error (response) ->
            ErrorReporter.loud("savePlaceOnClick Mark.create", response, { place_id: place_id, user_id: CurrentUser.id })
            $('.loading-mask').hide()
  }