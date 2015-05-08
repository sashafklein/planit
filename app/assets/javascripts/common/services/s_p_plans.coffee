angular.module("Common").service "SPPlans", (User, Plan, SPPlan, QueryString, ErrorReporter) ->
  class SPPlans

    constructor: ( user_id ) ->
      self = @
      self.plans = {}
      User.findPlans( user_id )
        .success (responses) -> _.forEach( responses, (r) -> self.plans[r.id] = new SPPlan( r ); self.plans[r.id]['type'] = 'travel' )
        .error (response) -> ErrorReporter.fullSilent( response, 'SinglePagePlans Plan constructor', user_id: user_id )

    addNewPlan: ( nearby, searchStrings ) ->
      self = @
      return unless Object.keys( nearby )?.length
      Plan.create( plan_name: nearby.name )
        .success (response) ->
          plan = new SPPlan( response )
          self.plans[ plan.id ] = plan
          self.plans[ plan.id ].setNearby( nearby, searchStrings )
          self.plans[ plan.id ].loadNearbyPlans()
        .error (response) -> ErrorReporter.fullSilent( response, 'SinglePagePlans Plan.create', { plan_name: name } )

    fetchPlan: ( plan_id ) ->
      self = @
      if @.plans[ plan_id ]?.items?.length # cached & loaded 
        QueryString.modify({ plan: plan_id })
        @.plans[ plan_id ].userResetNear = false
      else if @.plans[ plan_id ] # in cache but items not yet loaded
        self.loadPlan( plan_id )
        @.plans[ plan_id ].userResetNear = false
      else # not even in cache
        Plan.find( plan_id )
          .success (response) -> 
            self.plans[ response.id ] = new SPPlan( response )
            self.plans[ response.id ].type = 'followed' if !self.plans[ response.id ].userOwns()
            self.loadPlan( plan_id )
            self.plans[ response.id ].userResetNear = false
          .error (response) ->  ErrorReporter.fullSilent( response, "SPPlans loading plan #{ plan_id }" )

    loadPlan: ( plan_id ) ->
      @.plans[ plan_id ].loadNearbyPlans()
      @.plans[ plan_id ].loadItems()

    removePlan: ( plan_id ) ->
      plan = @.plans[ plan_id ]
      return unless confirm("Are you sure you want to delete '#{ plan.name }'?")
      plan.destroy( => delete @.plans[ plan_id ] )

    _bestDate: ( obj ) -> if obj.starts_at then obj.starts_at else obj.updated_at

    itemCount: -> x=0; _.forEach( @.plans, (p) -> x += p.place_ids.length ); return x

  return SPPlans