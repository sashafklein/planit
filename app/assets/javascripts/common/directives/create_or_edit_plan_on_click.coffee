angular.module("Common").directive 'createOrEditPlanOnClick', (Modal, CurrentUser, ErrorReporter) ->
  
  return {
    restrict: 'A'

    link: (scope, element, attrs) ->

      element.bind "click", (event) ->
        plan_id = scope.$eval attrs.createOrEditPlanOnClick
        if plan_id
          scope.modal = new Modal('createOrEditPlan').show({ plan_id: plan_id })
          # User.findPlans( scope.userId )
          #   .success (response) -> 
          #     scope.plans = response
          #     if plan = _.filter( _.map( scope.plans, (p) -> p.id == plan_id ) )[0]
        else
          scope.modal = new Modal('createOrEditPlan').show()
  }