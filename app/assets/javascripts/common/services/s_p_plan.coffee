angular.module("Common").service "SPPlan", (CurrentUser, User, Plan, Item, Note, SPItem, QueryString, RailsEnv, ErrorReporter, Spinner, Flash, $timeout) ->
  class SPPlan

    constructor: (plan) -> _.extend( @, plan )
    _planObj: -> new Plan( _.pick( @, ['id'] ) )
    _pusher: if RailsEnv.test then @_fakePusher else new Pusher( RailsEnv.pusher_key ) 
    _fakePusher:
      subscribe: -> 
        bind: -> alert("Pusher disabled in test mode")

    typeOf: -> if @userOwns() || @userCoOwns() then 'travel' else 'viewing'

    currentLocation: -> self = @; _.find( self.locations, (l) -> l.id == self.latest_location_id )

    # EDIT PLAN ITSELF

    rename: ( new_name, callback ) ->
      self = @
      @_planObj().update({ plan: { name: new_name } })
        .success (response) -> self.name = new_name; callback?()
        .error (response) -> ErrorReporter.defaultFull({ context: 'Failed to rename plan', list_id: self.id, new_name: new_name })

    destroy: ( callback ) ->
      self = @
      @_planObj().destroy()
        .success (response) -> callback?(); QueryString.modify({ plan: null })
        .error (response) -> ErrorReporter.fullSilent( response, 'SinglePagePlans SPPlan deletePlan', { plan_id: self.id } )

    setNearby: ( nearby, searchStrings ) ->
      self = @
      data = { asciiName: nearby.asciiName, adminName1: nearby.adminName1, countryName: nearby.countryName, fclName: nearby.fclName, geonameId: nearby.geonameId, lat: nearby.lat, lon: nearby.lng, searchStrings: searchStrings }
      @_planObj().addNearby(data)
        .success (response) -> 
          self.locations.unshift( response ) unless _.find( self.locations, (l) -> l.id == response.id )
          self.latest_location_id = response.id
          QueryString.modify({ plan: self.id })
        .error (response) -> ErrorReporter.fullSilent( response, 'Failed in setting self.id plan nearby' )

    removeNearby: ( nearby ) ->
      self = @
      @_planObj().removeNearby({ location_id: nearby['id'] })
        .success (response) -> 
          index = self.locations.indexOf( _.find( self.locations, (l) -> l.id == response ) )
          self.locations.splice( index, 1 ) if index != -1
          self.latest_location_id = null
        .error (response) -> ErrorReporter.fullSilent( response, 'Failed in removing nearby from plan' )

    # ADD TO PLAN

    addPlaces: (places, callback) ->
      self = @
      placeIds = _.map(places, 'id')
      @_planObj().addPlaces( placeIds )
        .success (response) -> callback?( response )
        .error (response) -> ErrorReporter.fullSilent( response, "SPPlan addPlaces", { place_ids: placeIds, plan_id: self.id } )

    addItem: ( fsOption, callback, callback2 ) ->
      self = @
      @_setAddItemSuccess( callback2 ) unless RailsEnv.test # Don't use Pusher or background-process this task in test env
      callback?()
      @_planObj().addItemFromPlaceData( fsOption )
        .success (response) -> if RailsEnv.test then self._affixItem(response, callback2)
        .error (response) -> ErrorReporter.defaultFull( response, 'SPPlan addItem', { option: JSON.stringify(fsOption), plan_id: self.id } )

    _setAddItemSuccess: ( callback ) ->
      self = @
      channel = @_pusher.subscribe( "add-item-from-place-data-to-plan-#{ @id }" )
      channel.bind 'added', (data) ->
        Item.find( data.item_id )
          .success (response) -> 
            self._affixItem(response, callback)
            self._pusher.unsubscribe( "add-item-from-place-data-to-plan-#{ self.id }" )
          .error (response) ->
            ErrorReporter.fullSilent( response, 'addBox _setAddItemSuccess', { item_id: data.item_id, plan_id: self.id } )
            self._pusher.unsubscribe( "add-item-from-place-data-to-plan-#{ self.id }" )

    _affixItem: (response, callback) ->
      new_item = _.extend( new SPItem( Item.generateFromJSON( response ) ), { index: @items.length, pane: 'list', notesSearched: true } )
      if !_.find(@items, (i) -> i.mark?.place?.id == new_item.mark?.place?.id )
        @items.unshift new_item
        @place_ids.unshift( new_item.mark?.place.id ) if new_item?.mark?.place?.id      
        @best_image = new_item.mark.place.images[0] if new_item?.mark?.place?.images?.length && @items?.length == 1
        callback?()
        QueryString.modify({m: null})

    # REMOVE FROM PLAN

    deleteItem: ( item ) ->
      return unless confirm("Delete #{item.mark.place.name} from '#{@name}'?")
      item.destroy( @_removeItemFromPlan( item ) )

    deleteItems: ( items, callback ) ->
      return unless confirm("Remove #{ items.length } items from '#{@name}'?")
      self = @
      itemIds = _.map( items, 'id' )
      places = _.map( items, 'mark.place' )

      @_planObj().destroyItems( null, itemIds ) # Method expects place_ids as first argument
        .success (response) ->
          self._removeItemsFromPlan(places)
          callback?()
        .error (response) ->
          ErrorReporter.fullSilent( response, 'SPPlan deleteItems', { item_ids: itemIds, plan_id: self.id })

    _removeItemsFromPlan: (places) ->
      self = @
      placeIds = _.map(places, 'id')
      itemsWithPlaces = _.filter( @items, (i) -> _.contains( placeIds, i.mark.place.id ) )

      _.forEach itemsWithPlaces, (item) -> 
        itemIndices = _.map( itemsWithPlaces, (i) -> self.items.indexOf(item) )
        _.forEach itemIndices, (index) -> self.items.splice(index, 1) unless index == -1 

      for place in places 
        placeIdIndex = @place_ids.indexOf( place.id )
        @place_ids.splice( placeIdIndex, 1 ) if placeIdIndex != -1

      @best_image = null if @items?.length == 0

    _removeItemFromPlan: ( item ) ->
      @_removeItemsFromPlan( _.compact([item?.mark?.place]) )

    # LOAD UP PLAN

    loadNearbyPlans: ->
      @nearbyPlans = {}
      # self = @
      # return unless Object.keys( nearby )?.length
      # Plan.locatedNear( "#{[nearby.lat,nearby.lon]}" )
      #   .success (response) ->
      #     _.forEach( response , (r) -> 
      #       self.nearbyPlans[ r.id ] = new SPPlan( r ) 
      #       self.nearbyPlans[ r.id ]['nearby'] = nearby 
      #     )
      #   .error (response) -> ErrorReporter.fullSilent( response, 'SinglePagePlans Plan.loadNearbyPlans', { coordinate: [nearby.lat,nearby.lon] } )

    loadItems: (options={}) ->
      self = @
      options.redirectAfterLoad ||= true

      if !@items?.length || !@fetchingItems || options.force
        @items = []
        @fetchingItems = true
        Item.where({ plan_id: @id })
          .success (response) ->
            _.forEach response , ( item, index ) ->
              i = _.extend( new SPItem( Item.generateFromJSON( item ) ), { index: index, pane: 'list', class: 'Item' } )
              self.items.push i
            self.itemsLoaded = true
            QueryString.modify({ plan: parseInt( self.id ) }) if options.redirectAfterLoad
            options.afterLoad( self.items ) if options.afterLoad?
            $timeout(-> self._fetchNotes() )
          .error (response) -> ErrorReporter.fullSilent( response, "SPPlan load list #{self.id}", { plan_id: self.id })

    _fetchNotes: ->
      self = @
      Note.findAllNotesInPlan( @id )
        .success (response) -> _.forEach( self.items, (i) -> i.note = _.find( response, (n) -> parseInt( n.obj_id ) == parseInt( i.id ) )?.body; i.notesSearched = true )
        .error (response) -> ErrorReporter.fullSilent( response, "SPPlan load list fetch original notes", { plan_id: @id })

    categories: ( categorizeBy ) -> #sorted alphabetically
      switch categorizeBy
        when 'type' then _.sortBy( _.uniq( _.map( @items, (i) -> i.meta_category ) ) , (c) -> return c )
        when 'alphabetical' then _.sortBy( _.uniq( _.compact( _.map( @items, (i) -> i.mark.place.names?[0]?[0] ) ) ) , (c) -> return c )
        when 'recent' then _.sortBy( _.uniq( _.map( @items, (i) -> x=i.updated_at.match(/(\d{4})-(\d{2})-(\d{2})/); return "#{x[2]}/#{x[3]}/#{x[1]}" ) ) , (c) -> return c )
        when 'locale' then _.sortBy( _.uniq( _.map( @items, (i) -> i.mark.place.locality ) ) , (c) -> return c )

    matchingItems: ( category, categorizeBy ) -> #sorted alphabetically
      switch categorizeBy
        when 'type' then _.sortBy( _.filter( @items, (i) -> i.meta_category == category ) , (i) -> return i.mark.place.names[0] )
        when 'alphabetical' then _.sortBy( _.filter( @items, (i) -> i.mark.place.names?[0]?[0] == category ) , (i) -> return i.mark.place.names[0] )
        when 'recent' then _.sortBy( _.filter( @items, (i) -> x=i.updated_at.match(/(\d{4})-(\d{2})-(\d{2})/); "#{x[2]}/#{x[3]}/#{x[1]}" == category ) , (i) -> return i.mark.place.names[0] )
        when 'locale' then _.sortBy( _.filter( @items, (i) -> i.mark.place.locality == category ) , (i) -> return i.mark.place.names[0] )
        else []

    hasCollaborators: -> @collaboratorIds()?.length > 0
    collaboratorIds: -> _.map( @collaborators, (c) -> c.id )
    userOwns: -> @user_id == CurrentUser.id
    userCoOwns: -> _.includes( @collaboratorIds, CurrentUser.id )
    ownerLoves: ( item ) -> _.includes( item.mark.place.lovers , @user_id )
    ownerVisited: ( item ) -> _.includes( item.mark.place.visitors , @user_id )

    # MANIFEST FUNCTIONS

    getManifestItems: (callback) ->
      self = @
      return null unless ( item_ids = _(self.manifest).select( (o) -> o.class == 'Item' ).map('id').value() ).length
      Item.where( id: item_ids )
        .success (response) ->
          if callback?
            callback _.map( self.manifest, (obj, index) -> self._manifestWrap( _.find(response, (i) -> i.id == obj.id ) || obj, index ) )
        .error (response) ->
          ErrorReporter.fullSilent( response, 'tripView getManifestItems', { list_id: s.m.plan().id, item_ids: item_ids } )

    _manifestWrap: (obj, index) ->
      return _.extend(obj, { index: index }) unless obj.mark_id? # is an Item
      _.extend( Item.generateFromJSON(obj) , { index: index } )

    addToManifest: (item, insertIndex, callback) ->
      self = @
      self._planObj().addToManifest(item, insertIndex)
        .success( (response) -> callback?(response) )
        .error( (response) -> self._manifestError('addToManifest', response) )

    removeFromManifest: (item, index, callback) ->
      self = @
      self._planObj().removeFromManifest(item, index)
        .success( (response) -> callback?(response) ).error( (response) -> self._manifestError('removeFromManifest', response) )

    moveInManifest: (from, to, callback) ->
      self = @
      self._planObj().moveInManifest(from, to)
        .success( (response) -> callback?(response) ).error( (response) -> self._manifestError('moveInManifest', response) )    

    _manifestError: (method, response) -> ErrorReporter.defaultFull( response, "SPPlan #{method}", { plan_id: self.id } )

    # FUNCTIONS ON PLAN

    copy: ->
      self = @
      if RailsEnv.test
        self._planObj().copy().success (response) -> window.location.replace("/plans/#{ response.id }")
      else
        channel = @_pusher.subscribe("copy-plan-#{self.id}") 
        channel.bind 'copied', (data) -> window.location.replace("/plans/#{ data.id }")
        Spinner.show()
        self._planObj().copy()
          .success (response) -> Spinner.hide()
          .error (response) -> ErrorReporter.defaultFull( response, "planSettings SPPlan copyList", { list_id: self.id } )


  return SPPlan