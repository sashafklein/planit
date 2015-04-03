angular.module("Common").directive 'addPlacesToPlanOnClick', (User, Modal, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'
    scope:
      name: '@'
      successFunction: '&'

    link: (scope, element, attrs) ->
      
      scope.userId = CurrentUser.id

      element.bind "click", (event) ->
        scope.place_ids = scope.$eval attrs.addPlacesToPlanOnClick
        User.findPlans( scope.userId )
          .success (response) -> 
            scope.plans = response
            scope.modal = new Modal('addToPlan').show({ plans: scope.plans, place_ids: scope.place_ids })
          .error (response) -> ErrorReporter.report({ user_id: CurrentUser.id, context: "Loading user plans inside addPlacesToPlanOnClick directive" })

  }