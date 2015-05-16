angular.module('Modals').directive 'createOrEditPlan', (Plan, Modal, ErrorReporter) ->
  return { 
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'modals/create_or_edit_plan.html'
    scope:
      data: '='
      headerTitle: '@'

    link: (s, e) ->

      s.plan_id = data.plan_id 
      if s.plan_id then s.title = 'Edit Your Guide' else s.title = 'Create a New Guide'

      s.changesMade = false

      s.cancel = -> new Modal('').hide()

      # s.removePlacesFromPlan = ( plan ) ->
      #   if confirm("Remove from '#{plan.name}'?")
      #     new Plan({ id: plan.id }).destroyItems( s.place_ids )
      #       .success (response) ->
      #         s.selectedPlans.splice( s.selectedPlans.indexOf( plan ), 1 )
      #         s.changesMade = true
      #       .error -> ErrorReporter.report({ context: 'Trying to remove places from a plan in createOrEditPlan modal', api_path: planObj.objectPath() })

      # s.addPlacesToPlan = ( plan ) ->
      #   new Plan({ id: plan.id }).addPlaces( s.place_ids )
      #     .success (response) ->
      #       s.selectedPlans.push plan
      #       s.guideName = null
      #       s.changesMade = true
      #     .error -> ErrorReporter.report({ context: 'Trying to add places to a plan in createOrEditPlan modal', api_path: planObj.objectPath() })

      # s.addPlacesToNewPlan = () ->
      #   if s.guideName.length > 1
      #     sameNamedPlans = _.filter( s.plans, (p) -> p.name.toLowerCase() == s.guideName.toLowerCase() )
      #     console.log sameNamedPlans
      #     if !sameNamedPlans.length
      #       Plan.create({ plan_name: s.guideName, place_ids: s.place_ids })
      #         .success (response) -> 
      #           plan = response
      #           s.selectedPlans.push plan
      #           s.guideName = null
      #           s.changesMade = true
      #         .error -> ErrorReporter.report({ context: 'Trying to create a new plan with places in createOrEditPlan modal', api_path: planObj.objectPath() })
      #     else if sameNamedPlans.length == 1
      #       s.addPlacesToPlan( sameNamedPlans[0] )
      #     else if sameNamedPlans.length > 1
      #       s.addPlacesToPlan( sameNamedPlans[0] )
      #       ErrorReporter.report({ context: 'Many plans with same name...', api_path: planObj.objectPath() })

  }

