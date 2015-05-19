angular.module("SPA").service "SPPlans", (User, Plan, SPPlan, QueryString, ErrorReporter) ->
  class SPPlans

    constructor: ( user_id ) ->
      self = @
      self.plans = {}
      self.nearbyPlans = {}
      User.findPlans( user_id )
        .success (responses) -> _.forEach( responses, (r) -> self.plans[r.id] = new SPPlan( r ); self.plans[r.id]['type'] = 'travel' )
        .error (response) -> ErrorReporter.fullSilent( response, 'SinglePagePlans Plan constructor', user_id: user_id )

    countryPlans: ( country ) ->
      return [] unless country
      self = @
      _.filter( self.plans, (p) -> _.find( p.locations, (l) -> l.countryId == country.geonameId ) )

    addNewPlan: ( nearby, searchStrings ) ->
      self = @
      return unless Object.keys( nearby )?.length
      Plan.create( plan_name: nearby.name )
        .success (response) ->
          plan = new SPPlan( response )
          self.plans[ plan.id ] = plan
          self.plans[ plan.id ].setNearby( nearby, searchStrings )
          # self.loadNearbyPlans( response.locations?[0]?.id )
        .error (response) -> ErrorReporter.fullSilent( response, 'SinglePagePlans Plan.create', { plan_name: name } )

    fetchPlan: ( plan_id ) ->
      self = @
      return unless plan_id
      if self.plans[ plan_id ] && !self.plans[ plan_id ]?.items?.length>0 # in cache but items not yet loaded
        self.loadPlan( plan_id )
        self.plans[ plan_id ].userResetNear = false
      else if self.plans[ plan_id ]?.items?.length>0 # cached & loaded 
        QueryString.modify({ plan: plan_id })
        self.plans[ plan_id ].userResetNear = false
      else # not even in cache
        Plan.find( plan_id )
          .success (response) ->
            self.plans[ response.id ] = new SPPlan( response )
            self.plans[ response.id ].type = 'followed' if !self.plans[ response.id ].userOwns()
            self.loadPlan( plan_id )
            self.plans[ response.id ].userResetNear = false
          .error (response) ->  ErrorReporter.fullSilent( response, "SPPlans loading plan #{ plan_id }" )

    # loadNearbyPlans: ( location_id ) ->
    #   return unless location_id || @.nearbyPlans?[ location_id ]
    #   self = @
    #   Plan.locatedNear( location_id )
    #     .success (response) ->
    #       self.nearbyPlans[ location_id ] = {}
    #       _.forEach( response , (r) -> self.nearbyPlans[ location_id ][ r.id ] = new SPPlan( r ) )
    #     .error (response) -> ErrorReporter.fullSilent( response, 'SinglePagePlans Plan.loadNearbyPlans', { coordinate: [nearby.lat,nearby.lon] } )

    loadPlan: ( plan_id ) ->
      # @.loadNearbyPlans( @.plans[ plan_id ].locations?[0]?.id )
      @.plans[ plan_id ].loadItems()

    removePlan: ( plan_id ) ->
      plan = @.plans[ plan_id ]
      return unless confirm("Are you sure you want to delete '#{ plan.name }'?")
      plan.destroy( => delete @.plans[ plan_id ] )

    _bestDate: ( obj ) -> if obj.starts_at then obj.starts_at else obj.updated_at

    itemCount: -> x=0; _.forEach( @.plans, (p) -> x += p.place_ids.length ); return x

  return SPPlans