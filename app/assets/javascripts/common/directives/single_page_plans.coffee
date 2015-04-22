angular.module("Common").directive 'singlePagePlans', (User, Plan, Mark, Item, Place, Note, Foursquare, ErrorReporter, CurrentUser, QueryString, Flash, $filter, $timeout, $location, $q, $http) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single_page_plans.html'

    link: (s, e, a) ->

      s.currentUserId = CurrentUser.id

      # QUERYSTRING MANAGE START DATA

      if plan_id = QueryString.get()['plan']
        Plan.find(plan_id)
          .success (response) ->
            s.list = s.plan = Plan.generateFromJSON( response )
            s.setList( s.list )
            if locale = QueryString.get()['near']
              s.nearby = locale
            else if mapCenter = QueryString.get()['m']
              s.nearbyFromMapCenter( mapCenter )

          .error (response) ->
            QueryString.modify({plan: null, near: null})
            ErrorReporter.defaultFull( response, "SinglePagePlans top Plan.find", { plan_id: plan_id } )

      # EXPAND/CONTRACT

      s.addBoxToggled = true
      s.addBoxManuallyToggled = false
      s.addBoxToggle = -> 
        s.addBoxToggled = !s.addBoxToggled
        s.addBoxManuallyToggled = true
      s.settingsBoxToggled = false
      s.settingsBoxToggle = -> s.settingsBoxToggled = !s.settingsBoxToggled

      s.setMode = (mode) -> 
        s.mode = mode
        QueryString.modify({mode: mode})
        if mode == 'map' then s.showMap = true else s.showMap = false
        if mapCenter = QueryString.get()['m'] then s.nearbyFromMapCenter( mapCenter )

      s.setModeViaQueryString = ->
        if mode_in_querystring = QueryString.get()['mode']
          s.mode = mode_in_querystring
          if s.mode == 'map' then s.showMap = true else s.showMap = false
        else
          s.mode = 'list'
          QueryString.modify({mode: 'list'})


      # LISTS & SETTING LISTS

      s.forbiddenNearby = []

      s.hoveringList = false
      s.listQuerySet = (name) -> s.hoveringList = true; s.listQuery = "Open => " + name
      s.listQueryReset = -> s.listQuery = null; s.hoveringList = false

      s.hasLists = -> s.lists?.length > 0

      s.getUsersLists = ->
        if s.currentUserId
          User.findPlans( s.currentUserId )
            .success (response) ->
              unsortedLists = Plan.generateFromJSON(response)
              s.lists = _.sortBy( unsortedLists, (l) -> s.bestListDate(l) ).reverse()
              s.isLoaded = true unless s.list
            .error (response) ->
              ErrorReporter.defaultFull( response, 'SinglePagePlans getUsersLists' )
              s.isLoaded = true 

      s.bestListDate = (list) -> if list.starts_at then list.starts_at else list.updated_at

      s.setListOnEnter = ->
        if s.listOptions().length == 1
          s.setList( s.listOptions()[0] ) 
        else
          s.setList()

      s.resetList = -> 
        s._setOnScope( [ 'list', 'listQuery', 'options', 'placeName', 'placeNearby', 'nearby', 'showMap', 'qsNearby'], null )
        s._setOnScope( [ 'items', 'places'], [] )
        $timeout(-> $('#guide').focus() if $('#guide') )
        QueryString.modify({plan: null, near: null, m: null, f: null})

      s.canAddList = -> s.listQuery?.length > 2 && ( !s.lists?.length || !s.listOptions()?.length || ( s.listOptions()?.length > 0 && !s.optionMatchesListQuery() ) )

      s.listClass = (mode) ->
        if mode == 'list' then 'sixteen columns' else 'ten columns'

      s.setList = (list) ->
        if list
          $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
          s._installList( list )
        else if list = s.optionMatchesListQuery()
          $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
          s._installList( list )
        else if s.canAddList
          if confirm("Create a new guide named '#{s.listQuery}'?")
            $('.loading-mask').show()
            $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
            Plan.create( plan_name: s.listQuery )
              .success (response) ->
                $('.loading-mask').hide()
                list = Plan.generateFromJSON(response)
                s._installList( list )
              .error (response) ->
                $('.loading-mask').hide()
                ErrorReporter.defaultFull( response, 'SinglePagePlans Plan.create', { plan_name: s.listQuery})

      s._installList = (list) ->
        QueryString.modify({plan: list.id})
        s.setModeViaQueryString()
        s.userOwnsList = if s.currentUserId == list.user_id then true else false
        s.plan = s.list = list
        s.lists.unshift(s.list) if s.lists && !_.find( s.lists, (l) -> l.id == s.list.id )
        s.getListItems()
        s.listQuery = list.name
        s.kmlPath = "/api/v1/plans/#{ list.id }/kml"
        s.printPath = "/plans/#{ list.id }/print"

      s.getListItems = ->
        return unless s.list?
        $('.searching-mask').show()
        s.isLoaded = false
        Item.where({ plan_id: s.list.id })
          .success (response) ->
            $('.searching-mask').hide()
            return unless s.list?
            
            s._setOnScope( ['items', 'places'], [] )
            _.forEach response , (item, index) ->
              i = _.extend( Item.generateFromJSON( item ), { index: index, pane: 'list' } )
              s.items.push i

            s.isLoaded = true

            s._getManifestItems()

            $timeout(-> s.initialSortItems() )
            $timeout(-> s.initializeItemsNotes() )
          .error (response) ->
            $('.searching-mask').hide()
            s.isLoaded = true
            ErrorReporter.defaultFull( response, 'SinglePagePlans getListItems', { plan_id: s.list.id })

      s.listOptions = ->
        filter = $filter('filter')
        return [] unless s.lists?.length
        filter(s.lists, s.listQuery)

      s.optionMatchesListQuery = -> _(s.listOptions()).find( (o) -> o.name.toLowerCase() == s.listQuery.toLowerCase() )

      s.rename = null
      s.renameList = ->
        if s.userOwnsList
          s.rename = s.list.name
          $timeout(-> $('#rename').focus() if $('#rename') )
          return
      s.saveRenameList = -> 
        s.list.update({ plan: { name: s.rename } })
          .success (response) ->
            s.list = Plan.generateFromJSON( response )
            s.cancelRenameList()
          .error (response) ->
            s.cancelRenameList()
            ErrorReporter.defaultFull({ context: 'Failed to rename plan', list_id: s.list.id})

      s.cancelRenameList = -> s.rename = null

      s.planImage = ( plan ) -> if plan && plan.best_image then plan.best_image.url else ''

      s.deleteList = ( list ) ->
        if confirm("Are you sure you want to delete '#{list.name}'?")
          $('.loading-mask').show()
          s.list.destroy()
            .success (response) ->
              listIndex = s.lists.indexOf( list )
              s.lists.splice( listIndex, 1 ) if listIndex > -1
              s.resetList() 
              $('.loading-mask').hide()
              return
            .error (response) ->
              ErrorReporter.defaultFull( response, 'SinglePagePlans deleteList', { plan_id: s.list.id } )
              $('.loading-mask').hide()
              return


      # ITEMS == SEARCH, ADD

      s.items = []
      s.itemsFirstLetters = []
      s.itemsTypes = []
      s.itemsRecent = []
      s.itemsLocales = []
      s.sortAscending = true
      s.categoryIs = null

      s.plansNoItems = -> s.lists?.length && !_.uniq( _.flatten( _.map( s.lists, (l) -> l.place_ids ) ) ).length

      s.hasItems = -> s.items?.length > 0

      # NEARBY

      s.canSetNearby = (nearby) -> nearby?.length > 2 && !_(s.forbiddenNearby).find( (o) -> o.toLowerCase() == nearby?.toLowerCase() )      
      s.setNearby = (nearby) -> 
        s.nearby = nearby if s.canSetNearby(nearby)
        $timeout(-> $('#place-name').focus() if $('#place-name') )
        QueryString.modify({ near: nearby })
        return

      s.resetNearby = -> 
        s._setOnScope( [ 'nearby', 'placeName', 'centerNearby' ], null )
        s.options = []
        $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
        QueryString.modify({ near: null })
        s.qsNearby = false
        return

      s.backspaced = 0
      s.removeTagOnBackspace = (event) ->
        if event.keyCode == 8
          unless s.placeName?.length > 0
            if s.backspaced > 0
              $timeout(-> $('span.chosen-input#chosen-nearby').removeClass("highlighted") )
              s.resetNearby()
              s.backspaced = 0
            else
              $timeout(-> $('span.chosen-input#chosen-nearby').addClass("highlighted") )
              s.backspaced = 1
        return

      # NOTES

      s.initializeItemsNotes = -> _.map( s.items, (item) -> s.fetchOriginalNote(item) )
      s.fetchOriginalNote = (item) ->
        Note.findByObject( item )
          .success (response) ->
            item.notesSearched = true
            if note = response.body then item.note = note
          .error (response) ->
            ErrorReporter.defaultFull( response, "singlePagePlans - fetchOriginalNote", { object_id: item.id, object_type: item.class })
            item.notesSearched = true

      s.saveNote = (item) ->
        return unless item?.note && item?.note.length > 0
        item.notesSearched = false
        Note.create({ note: { object_id: item.id, object_type: item.class, body: item.note } })
          .success (response) ->
            item.note = response.body
            item.notesSearched = true
          .error (response) ->
            ErrorReporter.defaultFull( response, "singlePagePlans - saveNote", { object_id: item.id, object_type: item.class, text: note })
            item.note = null
            item.notesSearched = true

      s.nextNote = (item) -> 
        return unless item
        if this_textarea = e.find("textarea#item_" + item.id)
          next_li = this_textarea.parents('li.plan-list-item').next('li.plan-list-item').find('textarea')
          next_ul = this_textarea.parents('.items-in-plan-category').next('.items-in-plan-category').find('textarea').first()
          next_li.focus() if next_li[0]
          next_ul.focus() if next_ul[0] && !next_li[0]
          this_textarea.blur() if !next_li[0] && !next_ul[0]
        return

      s.priorNote = (item) -> 
        return unless item
        if this_textarea = e.find("textarea#item_" + item.id)
          prior_li = this_textarea.parents('li.plan-list-item').prev('li.plan-list-item').find('textarea')
          prior_ul = this_textarea.parents('.items-in-plan-category').prev('.items-in-plan-category').find('textarea').last()
          prior_li.focus() if prior_li[0]
          prior_ul.focus() if prior_ul[0] && !prior_li[0]
          this_textarea.blur() if !prior_li[0] && !prior_ul[0]
        return


      # LIST SORTING

      s.initialSortItems = -> s.setCategoryAs('type')

      s.sortItems = ->
        return unless s.items
        s.itemsTypes = _.sortBy( _.uniq( _.map( s.items, (i) -> i.mark.place.meta_categories[0] ) ) , (i) -> return i )
        s.itemsTypes = s.itemsTypes.reverse() unless s.sortAscending
        s.itemsFirstLetters = _.sortBy( _.uniq( _.compact( _.map( s.items, (i) -> i.mark.place.names?[0]?[0] ) ) ) , (i) -> return i )
        s.itemsFirstLetters = s.itemsFirstLetters.reverse() unless s.sortAscending
        s.itemsRecent = _.sortBy( _.uniq( _.map( s.items, (i) -> i.updated_at_day ) ) , (i) -> return i )
        s.itemsRecent = s.itemsRecent.reverse() unless s.sortAscending
        s.itemsLocales = _.sortBy( _.uniq( _.map( s.items, (i) -> i.mark.place.locality ) ) , (i) -> return i )
        s.itemsLocales = s.itemsLocales.reverse() unless s.sortAscending
        s.buildCategories()

      s.buildCategories = ->
        s.categories = s.itemsTypes if s.categoryIs == 'type' 
        s.categories = s.itemsFirstLetters if s.categoryIs == 'alphabetical'
        s.categories = s.itemsRecent if s.categoryIs == 'recent'
        s.categories = s.itemsLocales if s.categoryIs == 'locale'        

      s.setCategoryAs = ( choice ) -> 
        if choice == s.categoryIs then s.sortAscending = !s.sortAscending else s.categoryIs = choice
        s.sortItems()

      s.metaClass = ( meta_category ) -> 
        colorClass = 'rainbow-print yellow' if meta_category == 'Area'
        colorClass = 'rainbow-print green' if meta_category == 'See'
        colorClass = 'rainbow-print bluegreen' if meta_category == 'Do'
        colorClass = 'rainbow-print turqoise' if meta_category == 'Relax'
        colorClass = 'rainbow-print blue' if meta_category == 'Stay'
        colorClass = 'rainbow-print purple' if meta_category == 'Drink'
        colorClass = 'rainbow-print magenta' if meta_category == 'Food'
        colorClass = 'rainbow-print pink' if meta_category == 'Shop'
        colorClass = 'rainbow-print orange' if meta_category == 'Help'
        colorClass = 'rainbow-print gray' if meta_category == 'Other'
        colorClass = 'rainbow-print gray' if meta_category == 'Transit'
        colorClass = 'rainbow-print gray' if meta_category == 'Money'
        colorClass ? colorClass : 'no-type'

      s.matchingItems = ( category ) ->
        if s.categoryIs == 'type' then matchingItems = _.filter( s.items, (i) -> i.mark.place.meta_categories?[0] == category )
        if s.categoryIs == 'alphabetical' then matchingItems = _.filter( s.items, (i) -> i.mark.place.names?[0]?[0] == category )
        if s.categoryIs == 'recent' then matchingItems = _.filter( s.items, (i) -> i.updated_at_day == category )
        if s.categoryIs == 'locale' then matchingItems = _.filter( s.items, (i) -> i.mark.place.locality == category )
        return matchingItems

      s.toDate = (yymmdd) -> 
        if yymmdd && yymmdd.length == 6
          "Updated on #{s.noneIfZero(yymmdd[2])}#{yymmdd[3]} / #{s.noneIfZero(yymmdd[4])}#{yymmdd[5]} / #{yymmdd[0]}#{yymmdd[1]}"
        else
          'Undated'
      s.noneIfZero = (digit) -> if digit == '0' then '' else digit

      # SEARCH AND ITEM ADDITION

      s.search = -> 
        s.options = [] if s.placeName?.length
        s._searchFunction() if s.placeName?.length > 1 && s.nearby?.length > 0

      s._searchFunction = _.debounce( (-> s._makeSearchRequest() ), 200 )

      s._makeSearchRequest = ->
        if s.nearby?.length && s.placeName?.length
          Foursquare.search(( s.qsNearby || s.nearby ), s.placeName)
            .success (response) ->
              s.options = Place.generateFromJSON(response)
            .error (response) ->
              if response && response.length > 0 && response.match(/failed_geocode: Couldn't geocode param/)?[0]
                Flash.warning("We're having trouble finding '#{s.nearby}'")
                s.forbiddenNearby.push s.nearby unless s.nearby == null
                s.nearby = null
                s.qsNearby = null
              else
                ErrorReporter.fullSilent(response, 'SinglePagePlans s._makeSearchRequest', { near: s.nearby, query: s.placeName }) if response.message != "Insufficient search params"

      s.hasOptions = -> s.options?.length>0

      s.lazyAddItem = -> s.addItem( s.options[0] ) if s.options?.length == 1

      s.addItem = (option) ->
        s.options = []
        s.placeName = null

        s.list.addItemFromPlaceData(option)
          .success (response) ->
            new_item = _.extend( Item.generateFromJSON( response ), { index: s.items.length, pane: 'list', notesSearched: true } )
            if !_.find(s.items, (i) -> i.mark?.place?.id == new_item.mark?.place?.id )
              s.items.unshift new_item
              for list in _.uniq( _.compact([s.list, _.find(s.lists, (l) -> l.id == s.list.id)]) )
                list.place_ids.unshift( new_item.mark?.place.id ) if new_item?.mark?.place?.id
            else
              Flash.warning("That place is already in your list!")
            QueryString.modify({m: null})
            if s.items?.length == 1
              s.initialSortItems()
              _.find(s.lists, (l) -> l.id == s.list.id).best_image = response.mark.place.images[0] if response?.mark?.place?.images?.length
            else
              s.sortItems()
          .error (response) ->
            ErrorReporter.defaultFull( response, 'SinglePagePlans addItem', { option: JSON.stringify(option), plan_id: s.list.id })

      s.typeIcon = (meta_category) -> 
        itemsWithIcon = _.filter( s.items, (i) -> i.mark.place.meta_categories[0] == meta_category )
        if itemsWithIcon[0] then itemsWithIcon[0].mark.place.meta_icon else ''

      ## DRAG-DROP

      s.addToManifest = (item, insertIndex=0) -> 
        s._runRequest( ( -> s.plan.addToManifest(item, insertIndex) ), 'addToManifest', { item_id: item.id })

      s.removeFromManifest = (itemIndex) ->
        item = s.manifestItems[itemIndex]
        s._runRequest( ( -> s.plan.removeFromManifest( item, itemIndex ) ), 'removeFromManifest', {item_id: item.id, remove_index: itemIndex} )

      s.moveInManifest = (from, to) ->
        s._runRequest( ( -> s.plan.moveInManifest(from, to) ), 'moveInManifest', { from: from, to: to } )

      s.toggleSelectedItem = (item) -> 
        s.selectedItem = (if s.selectedItem == item then null else item)

      s.isSelected = (item) -> s.selectedItem == item

      s.hoveringOver = (index) -> 
        s.selectedItem? && s.hoverIndex? && s.hoverIndex == index

      s.setHover = (index) -> s.hoverIndex = index

      s.insert = () ->
        return unless s.selectedItem? && (item = s.selectedItem)
        return unless s.hoverIndex?

        if item.pane == 'manifest'
          s.moveInManifest( item.index, s.hoverIndex )
        else
          s.addToManifest( item, s.hoverIndex )

        s.hoverIndex = s.selectedItem = null

      s._runRequest = (request, name='', extraReporting={}) ->
        request()
          .success (response) ->
            s._resetManifestItems(response)
          .error (response) ->
            ErrorReporter.defaultFull response, "singlePagePlans #{name}", _.extend({plan_id: s.plan.id}, extraReporting) 

      s._resetManifestItems = (response) ->
        s.plan.manifest = response
        newManifestItems = []
        _.forEach s.plan.manifest, (item, index) ->
          if found = s._findItem(item)
            newManifestItems.push _.extend(found, { $$hashKey: "object:#{index}", index: index, pane: 'manifest' })
        s.manifestItems = newManifestItems

      s._findItem = (manifestItem) -> 
        item = _.find(s.items, (i) -> s._identical(i, manifestItem)) || _.find(s.manifestItems, (i) -> s._identical(i, manifestItem) || {})
        return null unless item?.class
        s._dup(item)

      s._identical = (i1, i2) -> i1.class == i2.class && i1.id == i2.id

      s._getManifestItems = ->
        s.manifestItems ||= []
        _(s.plan.manifest).map( (item, index) -> 
          ( -> s._getManifestItem( item, index ) )
        ).reduce( ( (promise, next) -> promise.then(next) ), $q.when() )

      s._getManifestItem = (item, index) ->
        classObj = s._objectClasses[item.class]
        classObj.find(item.id)
          .success (response) ->
            s.manifestItems.push _.extend( classObj.generateFromJSON(response), { index: index, pane: 'manifest' } )
          .error (response) ->
            ErrorReporter.defaultFull( response, 'singlePagePlans getManifestItem', { plan_id: s.plan.id, item_id: item.id })

      s._dup = (object) -> s._objectClasses[object.class].generateFromJSON( _.extend({}, object) )

      s._objectClasses = { "Item": Item }

      # GEOCODING

      s.nearbyFromMapCenter = (mapCenter) ->
        return unless mapCenter?.length
        mapCenterSplit = mapCenter?.split(',')
        return unless mapCenterSplit && mapCenterSplit?.length > 1
        if s.qsNearby || ( !s.nearby?.length && !s.placeNearby?.length )
          lat = parseFloat( mapCenterSplit[0] )
          lon = parseFloat( mapCenterSplit[1] )
          geonamesQuery = "http://api.geonames.org/citiesJSON?north=#{ lat + 0.0075 }&south=#{ lat - 0.0075 }&east=#{ lon + 0.0125 }&west=#{ lon - 0.0125 }&username=planit&lang=en&style=full&callback=JSON_CALLBACK"
          $http.jsonp(geonamesQuery)
            .success (response) -> 
              cities = _.filter( response.geonames, (n) -> n.fclName == "city, village,..." )
              return unless cities[0]
              if s.qsNearby || ( !s.nearby?.length && !s.placeNearby?.length )
                s.nearby = "#{cities[0].name}" 
                s.qsNearby = "#{lat},#{lon}"
            .error (response) -> ErrorReporter("Geonames Cities Query not working on SinglePagePlan")


      # ITEM CONTROLS

      s.fsOpen = (item, doIt) ->
        return unless doIt and item.placeHref()
        window.open(item.placeHref(), '_blank')
        return

      s.delete = (item) ->
        return unless confirm("Delete #{item.mark.place.name} from '#{s.list.name}'?")
        return unless item?.mark?.place?.id
        item.destroy()
          .success (response) ->
            itemsWithPlace = _.filter( s.items, (i) -> i.mark.place.id == item.mark.place.id )
            itemsIndices = _.map( itemsWithPlace, (i) -> s.items.indexOf(i) )
            _.forEach(itemsIndices, (index) -> s.items.splice(index, 1) unless index == -1 )
            # # # manifestIndices = if s.manifestItems?.length then _(s.manifestItems).filter( (i) -> i.mark?.place.id == response.mark?.place.id ).map('index').value()
            # # _.forEach(manifestIndices, (index) -> s.manifestItems.splice(index, 1) unless index == -1 )
            for list in _.uniq( _.compact([s.list, _.find(s.lists, (l) -> l.id == s.list.id)]) )
              placeIdIndex = list.place_ids.indexOf( item.mark.place.id )
              if placeIdIndex != -1 then list.place_ids.splice( placeIdIndex, 1 )
              list.best_image = null if s.items?.length == 0
            s.sortItems()
            if confirm("Also delete from your saves?")
              Mark.remove( item.mark.place.id )
                .success (response) -> Flash.success("'#{item.mark.place.names[0]}' Deleted")
                .error (response) -> ErrorReporter.report({ place_id: item.mark.place.id, user_id: s.currentUserId, context: "Inside singlePagePlans directive, deleting a mark" })
          .error (response) ->
            ErrorReporter.defaultFull( response, 'singlePagePlans delete(item)', { item_id: item.id })

      s.ownerLoves = (item) -> _.includes( item.mark.place.lovers , s.list.user_id )
      s.ownerVisited = (item) -> _.includes( item.mark.place.visitors , s.list.user_id )

      s.currentUserSave = (item) -> _.filter( s.items, (i) -> i.id == item.id )[0].mark.place.savers.push s.currentUserId
      s.currentUserUnsave = (item) -> _.filter( s.items, (i) -> i.id == item.id )[0].mark.place.savers.splice( _.filter( s.items, (i) -> i.id == item.id )[0].mark.place.savers.indexOf( s.currentUserId ), 1 )
      s.currentUserSaved = (item) -> _.includes( item.mark.place.savers , s.currentUserId )

      s.currentUserLove = (item) -> _.filter( s.items, (i) -> i.id == item.id )[0].mark.place.lovers.push s.currentUserId
      s.currentUserUnlove = (item) -> _.filter( s.items, (i) -> i.id == item.id )[0].mark.place.lovers.splice( _.filter( s.items, (i) -> i.id == item.id )[0].mark.place.lovers.indexOf( s.currentUserId ), 1 )
      s.currentUserLoves = (item) -> _.includes( item.mark.place.lovers , s.currentUserId )

      s.currentUserBeen = (item) -> _.filter( s.items, (i) -> i.id == item.id )[0].mark.place.visitors.push s.currentUserId
      s.currentUserUnbeen = (item) -> _.filter( s.items, (i) -> i.id == item.id )[0].mark.place.visitors.splice( _.filter( s.items, (i) -> i.id == item.id )[0].mark.place.visitors.indexOf( s.currentUserId ), 1 )
      s.currentUserVisited = (item) -> _.includes( item.mark.place.visitors , s.currentUserId )

      s.hovering = ( item ) -> s.hoveredId = item.id
      s.unhovering = -> s.hoveredId = null

      # META

      s._setOnScope = (list, value = null) -> _.forEach list, (i) -> s[i] = ( if value? then _.clone(value) else null )

      # INITIALIZE

      s.getUsersLists()
      $timeout(-> $('#guide').focus() if $('#guide') ) unless s.list

      window.s = s
    }