angular.module("Common").directive 'removePlaceOnClick', (Mark, Modal, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'
    scope:
      successFunction: '&'

    link: (scope, element, attrs) ->
      
      element.bind "click", (event) ->
      #   scope.modal = new Modal('').show({ remove: 'scope.act()' })
      # scope.act = ->
        if confirm('Are You Sure?')
          place_id = scope.$eval attrs.removePlaceOnClick 
          Mark.remove( place_id )
            .success (response) ->
              if scope.successFunction? then scope.successFunction() else true
            .error (response) ->
              ErrorReporter.report({ place_id: place_id, user_id: CurrentUser.id, context: "Inside removePlaceOnClick directive" })
  }