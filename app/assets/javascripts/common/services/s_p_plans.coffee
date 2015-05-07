angular.module("Common").service "SPPlans", (User, Plan, SPPlan, QueryString, ErrorReporter) ->
  class SPPlans

    constructor: ( user_id ) ->
      self = @
      self.plans = {}
      User.findPlans( user_id )
        .success (responses) -> _.forEach( responses, (r) -> self.plans[r.id] = new SPPlan( r ); self.plans[r.id]['type'] = 'travel' )
        .error (response) -> ErrorReporter.fullSilent( response, 'SinglePagePlans Plan constructor', user_id: user_id )

    addNewPlan: ( nearby ) ->
      self = @
      return unless Object.keys( nearby )?.length
      Plan.create( plan_name: nearby.name )
        .success (response) ->
          plan = new SPPlan( response )
          self.plans[ plan.id ] = plan
          self.plans[ plan.id ]['nearby'] = nearby
          QueryString.modify({ plan: parseInt( plan.id ) })
        .error (response) -> ErrorReporter.fullSilent( response, 'SinglePagePlans Plan.create', { plan_name: name } )

    fetchCoLocatedPlans: ( nearby ) ->
      @.coLocatedPlans = {}
      self = @
      return unless Object.keys( nearby )?.length
      Plan.locatedNear( "#{[nearby.lat,nearby.lon]}" )
        .success (response) ->
          _.forEach( response , (r) -> 
            self.coLocatedPlans[ r.id ] = new SPPlan( r ) 
            self.coLocatedPlans[ r.id ]['nearby'] = nearby 
          )
        .error (response) -> ErrorReporter.fullSilent( response, 'SinglePagePlans Plan.fetchCoLocatedPlans', { coordinate: [nearby.lat,nearby.lon] } )

    fetchPlan: ( plan_id ) ->
      self = @
      if @.plans[ plan_id ]?.items?.length then QueryString.modify({ plan: plan_id })
      else if @.plans[ plan_id ] then @.plans[ plan_id ].loadItems()
      else
        Plan.find( plan_id )
          .success (response) -> 
            self.plans[ response.id ] = new SPPlan( response )
            self.plans[ response.id ].type = 'followed' if !self.plans[ response.id ].userOwns()
            self.plans[ response.id ].loadItems()
          .error (response) ->  ErrorReporter.fullSilent( response, "SPPlans loading plan #{ plan_id }" )

    removePlan: ( plan_id ) ->
      plan = @.plans[ plan_id ]
      return unless confirm("Are you sure you want to delete '#{ plan.name }'?")
      plan.destroy( => delete @.plans[ plan_id ] )

    _bestDate: ( obj ) -> if obj.starts_at then obj.starts_at else obj.updated_at

    itemCount: -> x=0; _.forEach( @.plans, (p) -> x += p.place_ids.length ); return x

  return SPPlans