angular.module("Common").service "SPList", (User, Plan, Item, Note, ErrorReporter) ->
  class SPList

    constructor: (plan) -> @originalPlan = plan

    addItem: ( option ) ->
      @originalPlan.addItem()
      s.m.placeNameOptions = []
      s.placeName = null

      s._setAddItemSuccess()
      s.m.addingItem = true
      @originalPlan.addItemFromPlaceData(option)
        .success (response) ->
          Flash.success("Adding '#{ response.name }' to your list. It should appear shortly")
        .error (response) ->
          s.m.addingItem = false
          ErrorReporter.defaultFull( response, 'SinglePagePlans addItem', { option: JSON.stringify(option), plan_id: @originalPlan.id } )

    _setAddItemSuccess = ->
      channel = s.m.pusher.subscribe( "add-item-from-place-data-to-plan-#{ @originalPlan.id }" )
      channel.bind 'added', (data) ->
        Item.find( data.item_id )
          .success (response) -> 
            s._affixItem(response)
            s.m.pusher.unsubscribe( "add-item-from-place-data-to-plan-#{ @originalPlan.id }" )
          .error (response) ->
            ErrorReporter.fullSilent( response, 'addBox _setAddItemSuccess', { item_id: data.item_id, plan_id: @originalPlan.id } )
            s.m.pusher.unsubscribe( "add-item-from-place-data-to-plan-#{ @originalPlan.id }" )

    _affixItem = (response) ->
      new_item = _.extend( Item.generateFromJSON( response ), { index: s.m.items.length, pane: 'list', notesSearched: true } )
      
      if !_.find(s.m.items, (i) -> i.mark?.place?.id == new_item.mark?.place?.id )
        s.m.items.unshift new_item
        for list in _.uniq( _.compact([@originalPlan, _.find(@originalPlans, (l) -> l.id == @originalPlan.id)]) )
          list.place_ids.unshift( new_item.mark?.place.id ) if new_item?.mark?.place?.id
      
      QueryString.modify({m: null})
      
      if s.m.items?.length == 1
        s.m.initialSortItems()
        _.find(@originalPlans, (l) -> l.id == @originalPlan.id).best_image = response.mark.place.images[0] if response?.mark?.place?.images?.length
      else
        s.m.sortItems()

    load: ->
      unless @originalPlan.items?.length
        $('.loading-mask').show()
        Item.where({ plan_id: @originalPlan.id })
          .success (response) ->
            _.forEach response , ( item, index ) ->
              i = _.extend( new SPItem( Item.generateFromJSON( item ) ), { index: index, pane: 'list' } )
              @originalPlan.items.push i
            $timeout(-> @_fetchNotes() )
            $('.loading-mask').hide()
          .error (response) ->
            $('.loading-mask').hide()
            ErrorReporter.silentFull( response, "SPList load list #{@originalPlan.id}", { plan_id: @originalPlan.id })

    _fetchNotes: ->
      Note.findAllNotesInPlan( @originalPlan.id )
        .success (response) ->
          _.map( @originalPlan.items, (i) -> i.note = _.find( response, (n) -> parseInt( n.object_id ) == parseInt( i.id ) )?.body; i.notesSearched = true )
        .error (response) ->
          ErrorReporter.silentFull( response, "SPList load list fetch original notes", { plan_id: @originalPlan.id })

    deleteItem: ( item ) ->
      return unless confirm("Delete #{item.mark.place.name} from '#{@originalPlan.name}'?")
      item.destroy()
        .success (response) ->
          itemsWithPlace = _.filter( @originalPlan.items, (i) -> i.mark.place.id == item.mark.place.id )
          itemsIndices = _.map( itemsWithPlace, (i) -> @originalPlan.items.indexOf(i) )
          _.forEach(itemsIndices, (index) -> @originalPlan.items.splice(index, 1) unless index == -1 )
          placeIdIndex = @originalPlan.place_ids.indexOf( item.mark.place.id )
          if placeIdIndex != -1 then @originalPlan.place_ids.splice( placeIdIndex, 1 )
          @originalPlan.best_image = null if @originalPlan.items?.length == 0

          s.m.sortItems()

          Mark.remove( item.mark.place.id )
            .success (response) -> Flash.success("'#{item.mark.place.names[0]}' Deleted")
            .error (response) -> ErrorReporter.report({ place_id: item.mark.place.id, user_id: s.m.currentUserId, context: "Inside singlePagePlans directive, deleting a mark" })
        .error (response) ->
          ErrorReporter.defaultFull( response, 'singlePagePlans delete(item)', { item_id: item.id })

    # # SORTING

    # s.m.itemsFirstLetters = []
    # s.m.itemsTypes = []
    # s.m.itemsRecent = []
    # s.m.itemsLocales = []
    # s.m.sortAsc = true
    # s.m.categoryIs = null
    # s.m.initialSortItems = -> s.m.setCategoryAs('type')
    # s.m.sortItems = ->
    #   return unless s.m.items?.length
    #   s.m.itemsTypes = _.sortBy( _.uniq( _.map( s.m.items, (i) -> i.mark.place.meta_categories[0] ) ) , (i) -> return i )
    #   s.m.itemsTypes = s.m.itemsTypes.reverse() unless s.sortAsc
    #   s.itemsFirstLetters = _.sortBy( _.uniq( _.compact( _.map( s.m.items, (i) -> i.mark.place.names?[0]?[0] ) ) ) , (i) -> return i )
    #   s.itemsFirstLetters = s.itemsFirstLetters.reverse() unless s.sortAsc
    #   s.itemsRecent = _.sortBy( _.uniq( _.map( s.m.items, (i) -> x=i.updated_at.match(/(\d{4})-(\d{2})-(\d{2})/); return "#{x[2]}/#{x[3]}/#{x[1]}" ) ) , (i) -> return i )
    #   s.itemsRecent = s.itemsRecent.reverse() unless s.sortAsc
    #   s.itemsLocales = _.sortBy( _.uniq( _.map( s.m.items, (i) -> i.mark.place.locality ) ) , (i) -> return i )
    #   s.itemsLocales = s.itemsLocales.reverse() unless s.sortAsc
    #   s.buildCategories()
    # s.m.setCategoryAs = ( choice ) -> 
    #   if choice == s.m.categoryIs then s.sortAsc = !s.sortAsc else s.m.categoryIs = choice
    #   s.m.sortItems()


  return SPList