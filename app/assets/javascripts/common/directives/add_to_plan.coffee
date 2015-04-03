angular.module('Common').directive 'addToPlan', (Plan, Modal, ErrorReporter) ->
  return { 
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'add_to_plan.html'
    scope:
      data: '='
      headerTitle: '@'

    link: (s, e) ->

      # ONLY PERMIT PLACES WITH MARKS
      s.place_ids = s.data.place_ids
      s.plans = s.data.plans
      s.selectedPlans = _.filter( s.plans, (p) -> _.all( s.place_ids, (id) -> _.include( p.place_ids, id ) ) )
      s.changesMade = false

      s.cancel = -> new Modal('').hide()

      s.removePlacesFromPlan = ( plan ) ->
        if confirm("Remove from '#{plan.name}'?")
          new Plan({ id: plan.id }).destroyItems( s.place_ids )
            .success (response) ->
              s.selectedPlans.splice( s.selectedPlans.indexOf( plan ), 1 )
              s.changesMade = true
            .error -> ErrorReporter.report({ context: 'Trying to remove places from a plan in addToPlan modal', api_path: planObj.objectPath() })

      s.addPlacesToPlan = ( plan ) ->
        new Plan({ id: plan.id }).addItems( s.place_ids )
          .success (response) ->
            s.selectedPlans.push plan
            s.guideName = null
            s.changesMade = true
          .error -> ErrorReporter.report({ context: 'Trying to add places to a plan in addToPlan modal', api_path: planObj.objectPath() })

      s.addPlacesToNewPlan = () ->
        if s.guideName && s.guideName.length > 1
          sameNamedPlans = _.filter( s.plans, (p) -> p.name.toLowerCase() == s.guideName.toLowerCase() )
          console.log sameNamedPlans
          if !sameNamedPlans.length
            Plan.create({ plan_name: s.guideName, place_ids: s.place_ids })
              .success (response) -> 
                plan = response
                s.selectedPlans.push plan
                s.guideName = null
                s.changesMade = true
              .error -> ErrorReporter.report({ context: 'Trying to create a new plan with places in addToPlan modal', api_path: planObj.objectPath() })
          else if sameNamedPlans.length == 1
            s.addPlacesToPlan( sameNamedPlans[0] )
          else if sameNamedPlans.length > 1
            s.addPlacesToPlan( sameNamedPlans[0] )
            ErrorReporter.report({ context: 'Many plans with same name...', api_path: planObj.objectPath() })

  }

