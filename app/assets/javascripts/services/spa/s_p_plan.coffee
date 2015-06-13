angular.module("SPA").service "SPPlan", (CurrentUser, User, Plan, Item, Note, SPItem, QueryString, RailsEnv, ErrorReporter, Spinner, Flash, $timeout) ->
  class SPPlan

    constructor: (plan) -> _.extend( @, plan )
    _planObj: -> new Plan( _.pick( @, ['id'] ) )
    _pusher: if RailsEnv.test then @_fakePusher else new Pusher( RailsEnv.pusher_key ) 
    _fakePusher:
      subscribe: -> 
        bind: -> alert("Pusher disabled in test mode")

    typeOf: -> if @userOwns() || @userCoOwns() then 'travel' else 'viewing'

    latestLocation: -> 
      self = @
      _.find( self.locations, (l) -> parseInt(l.id) == parseInt(self.latest_location_id) ) if self.latest_location_id
      
    currentLocation: -> current = @latestLocation(); return current unless current?.fcode=="PCLI"

    # EDIT PLAN ITSELF

    rename: ( new_name, callback ) ->
      self = @
      @_planObj().update({ plan: { name: new_name } })
        .success (response) -> self.name = new_name; callback?()
        .error (response) -> ErrorReporter.loud( response, 'SPPlan rename', { list_id: self.id, new_name: new_name })

    destroy: ( callback ) ->
      self = @
      @_planObj().destroy()
        .success (response) -> callback?(); QueryString.modify({ plan: null })
        .error (response) -> ErrorReporter.silent( response, 'SinglePagePlans SPPlan deletePlan', { plan_id: self.id } )

    setNearby: ( nearby, searchStrings ) ->
      self = @
      data = { name: nearby.name, asciiName: nearby.asciiName, adminId1: nearby.adminId1, adminName1: nearby.adminName1, adminId2: nearby.adminId2, adminName2: nearby.adminName2, countryId: nearby.countryId, countryName: nearby.countryName, fcode: nearby.fcode, geonameId: nearby.geonameId, lat: nearby.lat, lon: nearby.lng, searchStrings: searchStrings }
      @_planObj().addNearby(data)
        .success (response) -> 
          self.locations[ response.id ] = response unless self.locations[ response.id ]
          self.latest_location_id = parseInt( response.id )
          QueryString.modify({ plan: self.id })
        .error (response) -> ErrorReporter.silent( response, 'Failed in setting self.id plan nearby' )

    removeNearby: ( nearby ) ->
      self = @
      @_planObj().removeNearby({ location_id: nearby['id'] })
        .success (response) -> 
          delete self.locations[ nearby['id'] ]
          self.latest_location_id = null
        .error (response) -> ErrorReporter.silent( response, 'Failed in removing nearby from plan' )

    # ADD TO PLAN

    addItems: (items, delay=true, callback) ->
      self = @
      itemIds = _.map(items, 'id')
      if delay && !RailsEnv.test
        @_setAddItemsSuccess( callback )
        @_planObj().addItems( itemIds, { delay: true } ).error (response) -> ErrorReporter.silent( response, "SPPlan addItems", { item_ids: itemIds, plan_id: self.id } )
      else
        @_planObj().addItems( itemIds )
          .success (response) -> self._afterAddItemsSuccess(); callback?( response )
          .error (response) -> ErrorReporter.silent( response, "SPPlan addItems", { item_ids: itemIds, plan_id: self.id } )

    _setAddItemsSuccess: (callback) ->
      self = @
      channel = @_pusher.subscribe( "add-items-to-plan-#{ @id }" )
      channel.bind 'added', (data) -> 
        self._afterAddItemsSuccess()
        self._pusher.unsubscribe( "add-items-to-plan-#{ self.id }" )
        callback?(data) 

    _afterAddItemsSuccess: ->
      afterLoad = (plan) -> plan.place_ids = _.map( plan.items, 'mark.place.id' )
      @loadItems({ force: true, dontRedirectAfterLoad: true, afterLoad: afterLoad }) # Force reload, don't update QS, and update plan's place_ids

    addItem: ( fsOption, callback, callback2 ) ->
      self = @
      @_setAddItemSuccess( callback2 ) unless RailsEnv.test # Don't use Pusher or background-process this task in test env
      callback?()
      @_planObj().addItemFromPlaceData( fsOption )
        .success (response) -> if RailsEnv.test then self._affixItem(response, callback2)
        .error (response) -> ErrorReporter.loud( response, 'SPPlan addItem', { option: JSON.stringify(fsOption), plan_id: self.id } )

    _setAddItemSuccess: ( callback ) ->
      self = @
      channel = @_pusher.subscribe( "add-item-from-place-data-to-plan-#{ @id }" )
      channel.bind 'added', (data) ->
        Item.find( data.item_id )
          .success (response) -> 
            self._affixItem(response, callback)
            self._pusher.unsubscribe( "add-item-from-place-data-to-plan-#{ self.id }" )
          .error (response) ->
            ErrorReporter.silent( response, 'addBox _setAddItemSuccess', { item_id: data.item_id, plan_id: self.id } )
            self._pusher.unsubscribe( "add-item-from-place-data-to-plan-#{ self.id }" )

    _affixItem: (response, callback) ->
      new_item = _.extend( new SPItem( Item.generateFromJSON( response ) ), { index: @items.length, pane: 'list' } )
      new_item.mark.notesSearched = true if new_item.mark
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
          ErrorReporter.silent( response, 'SPPlan deleteItems', { item_ids: itemIds, plan_id: self.id })

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

    loadItems: (opts={}, callback) ->
      self = @

      if !@items?.length || !@fetchingItems || opts.force
        $timeout(-> self._fetchNotes() )
        @fetchingItems = true
        Item.where({ plan_id: @id })
          .success (response) ->
            self.items = []
            _.forEach response , ( item, index ) ->
              i = _.extend( new SPItem( Item.generateFromJSON( item ) ), { index: index, pane: 'list', class: 'Item' } )
              self.items.push i
            self.itemsLoaded = true
            QueryString.modify({ plan: parseInt( self.id ) }) unless opts.dontRedirectAfterLoad
            opts.afterLoad( self ) if opts.afterLoad?
            callback?()
          .error (response) -> ErrorReporter.silent( response, "SPPlan load list #{self.id}", { plan_id: self.id })

    _fetchNotes: ->
      self = @
      Note.findAllNotesInPlan( self.id )
        .success (response) -> 
          self.attachNotesToItemsWhenItems( response )
        .error (response) -> ErrorReporter.silent( response, "SPPlan load list fetch original notes", { plan_id: @id })
    attachNotesToItemsWhenItems: (response) ->
      self = @
      if self.items?
        _.forEach self.items, (i) -> 
          return unless i.mark?
          i.mark.note = _.find( response, (n) -> parseInt( n.obj_id ) == parseInt( i.mark_id ) )?.body
          i.mark.notesSearched = true
      else
        $timeout( ( -> self.attachNotesToItemsWhenItems(response) ), 200)

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
          ErrorReporter.silent( response, 'tripView getManifestItems', { list_id: s.m.plan().id, item_ids: item_ids } )

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

    _manifestError: (method, response) -> ErrorReporter.loud( response, "SPPlan #{method}", { plan_id: self.id } )

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
          .error (response) -> ErrorReporter.loud( response, "planSettings SPPlan copyList", { list_id: self.id } )


  return SPPlan