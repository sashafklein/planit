angular.module("SPA").service "SPPlans", (User, Plan, SPPlan, SPUsers, QueryString, ErrorReporter, $timeout) ->
  class SPPlans

    constructor: ( user_id ) ->
      self = @
      self.plans = {}
      self.userPlansLoaded = {}
      @userPlans( user_id )

    userPlans: ( user_id ) ->
      self = @
      return unless user_id
      userPlansFound = _.filter( self.plans, (p) -> p.user.id == user_id )
      return userPlansFound if userPlansFound?.length
      User.findPlans( user_id )
        .success (responses) -> 
          _.forEach responses, (r) -> 
            self.plans[r.id] = new SPPlan( r )
          $timeout(-> self.userPlansLoaded[ user_id ] = true )
        .error (response) -> ErrorReporter.silent( response, 'SinglePagePlans Plan constructor', user_id: user_id )
      # order by most recently updated?
      return _.filter( self.plans, (p) -> p.user.id == user_id ) 

    inCountries: ( cntryGeonames ) ->
      self = @
      return [] unless cntryGeonames?.length > 0
      _.filter( self.plans, (p) -> _.find( p.locations, (l) -> _.include( cntryGeonames, parseInt(l.countryId) ) ) )

    addNewPlan: ( nearby, searchStrings ) ->
      self = @
      return unless Object.keys( nearby )?.length
      Plan.create( plan_name: nearby.name )
        .success (response) ->
          plan = new SPPlan( response )
          self.plans[ plan.id ] = plan
          self.plans[ plan.id ].locations = {}
          self.plans[ plan.id ].setNearby( nearby, searchStrings )
          # self.loadNearbyPlans( response.locations?[0]?.id )
        .error (response) -> ErrorReporter.silent( response, 'SinglePagePlans Plan.create', { plan_name: name } )

    fetchPlan: ( plan_id, callback ) ->
      self = @
      return unless plan_id
      if self.plans[ plan_id ] && !self.plans[ plan_id ]?.items?.length>0 # in cache but items not yet loaded
        self.plans[ plan_id ].loadItems( callback )
        self.plans[ plan_id ].userResetNear = false
      else if self.plans[ plan_id ]?.items?.length>0 # cached & loaded 
        QueryString.modify({ plan: plan_id })
        self.plans[ plan_id ].userResetNear = false
        callback?()
      else # not even in cache
        Plan.find( plan_id )
          .success (response) ->
            self.plans[ response.id ] = new SPPlan( response )
            self.plans[ response.id ].type = 'followed' if !self.plans[ response.id ].userOwns()
            self.plans[ response.id ].loadItems( callback )
            self.plans[ response.id ].userResetNear = false
          .error (response) ->  ErrorReporter.silent( response, "SPPlans loading plan #{ plan_id }" )

    removePlan: ( plan_id ) ->
      plan = @.plans[ plan_id ]
      return unless confirm("Are you sure you want to delete '#{ plan.name }'?")
      plan.destroy( => delete @.plans[ plan_id ] )

    _bestDate: ( obj ) -> if obj.starts_at then obj.starts_at else obj.updated_at

    itemCount: -> x=0; _.forEach( @.plans, (p) -> x += p.place_ids.length ); return x

  return SPPlans