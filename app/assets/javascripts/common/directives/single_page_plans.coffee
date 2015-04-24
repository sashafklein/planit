angular.module("Common").directive 'singlePagePlans', (User, Plan, Mark, Item, Place, Note, Foursquare, QueryString, Geonames, CurrentUser, ErrorReporter, Flash, $filter, $timeout, $location, $q) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single_page_plans.html'

    link: (s, e, a) ->

      s.currentUserId = CurrentUser.id
      s.currentUserName = CurrentUser.name
      # s.bestPageTitle = -> if s.list then s.list.name else "#{s.currentUserName}'s Planit"
      s.userOwns = ( obj ) -> s.currentUserId == obj.user_id



      # QUERYSTRING MANAGE START DATA

      if plan_id = QueryString.get()['plan']
        Plan.find(plan_id)
          .success (response) ->
            s.list = s.plan = Plan.generateFromJSON( response )
            s.setList( s.list )
            if locale = QueryString.get()['near']
              nameAndLatLon = locale.split(',,')
              if nameAndLatLon?.length == 2
                name = nameAndLatLon[0]
                latLon = nameAndLatLon[1].split(',')
                if latLon?.length == 2
                  s.nearby = { name: name, lat: latLon[0], lon: latLon[1] }
            # else if mapCenter = QueryString.get()['m']
            #   s.nearbyFromMapCenter( mapCenter )

          .error (response) ->
            QueryString.modify({plan: null, near: null})
            ErrorReporter.defaultFull( response, "SinglePagePlans top Plan.find", { plan_id: plan_id } )




      # EXPAND/CONTRACT

      s.mainMenuToggled = false
      s.toggleMainMenu = -> s.mainMenuToggled = !s.mainMenuToggled

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
        # if mapCenter = QueryString.get()['m'] then s.nearbyFromMapCenter( mapCenter )

      s.setModeViaQueryString = ->
        if mode_in_querystring = QueryString.get()['mode']
          s.mode = mode_in_querystring
          if s.mode == 'map' then s.showMap = true else s.showMap = false
        else
          s.mode = 'list'
          QueryString.modify({mode: 'list'})




      # VALIDATE LOCATION AND START LIST

      s.searchPlanNearby = -> 
        s.planNearbyOptions = [] if s.planNearby?.length
        s._searchPlanNearbyFunction() if s.planNearby?.length > 1

      s._searchPlanNearbyFunction = _.debounce( (-> s._searchPlanNearby() ), 500 )

      s.planNearbyOptionSelectable = (option) -> option?.name?.toLowerCase() == s.planNearby?.split(',')[0]?.toLowerCase()

      s.noPlanNearbyResults = -> s.planNearby?.length>1 && s.planNearbyWorking<1 && s.planNearbyOptions?.length<1
      s.cleanPlanNearbyOptions = -> s.planNearbyOptions = []

      s.planNearbyWorking = 0
      s._searchPlanNearby = ->
        return unless s.planNearby?.length > 1
        s.planNearbyWorking++
        Geonames.search( s.planNearby )
          .success (response) ->
            s.planNearbyWorking--
            s.planNearbyOptions = response.geonames
            _.map( s.planNearbyOptions, (o) -> 
              o.lon = o.lng; o.qualifiers = _.uniq( _.compact( [ o.adminName1 unless o.name == o.adminName1, o.countryCode ] ) ).join(", ")
            )
          .error (response) -> 
            s.planNearbyWorking--
            ErrorReporter.fullSilent(response, 'SinglePagePlans s.searchPlanNearby', { query: s.planName })

      s.startListNearBestOption = ->
        return unless s.planNearbyOptions?.length
        keepGoing = true
        _.forEach( s.planNearbyOptions, (o) ->
          if s.planNearbyOptionSelectable(o) && keepGoing
            s.startListNear(o)
            keepGoing = false
        )

      s.startListNear = (option) ->
        return unless option?.name && option?.lat && option?.lon
        s.newList( option.name + " Guide" )
        s.setNearby( option )

      # s.nearbyFromMapCenter = (mapCenter) ->
      #   return unless mapCenter?.length
      #   mapCenterSplit = mapCenter?.split(',')
      #   return unless mapCenterSplit && mapCenterSplit?.length > 1
      #   if s.qsNearby || ( !s.nearby?.length && !s.placeNearby?.length )
      #     lat = parseFloat( mapCenterSplit[0] )
      #     lon = parseFloat( mapCenterSplit[1] )
      #     s.qsNearby = "#{lat},#{lon}"
      #     geonamesQuery = "https://api.geonames.org/citiesJSON?north=#{ lat + 0.0075 }&south=#{ lat - 0.0075 }&east=#{ lon + 0.0125 }&west=#{ lon - 0.0125 }&username=planit&lang=en&style=full&callback=JSON_CALLBACK"
      #     $http.jsonp(geonamesQuery)
      #       .success (response) -> 
      #         cities = _.filter( response.geonames, (n) -> n.fclName == "city, village,..." )
      #         return unless cities[0]
      #         if s.qsNearby || ( !s.nearby?.length && !s.placeNearby?.length )
      #           s.nearby = "#{cities[0].name}" 
      #           s.qsNearby = "#{lat},#{lon}"
      #       .error (response) -> ErrorReporter("Geonames Cities Query not working on SinglePagePlan")




      # LISTS & SETTING LISTS

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

      s.bestListNearby = (items) -> 
        return unless items?.length && items[0]?.mark?.place
        mostRecentItem = _.sortBy( items, (i) -> i.updated_at_day ).reverse()[0]
        locale = mostRecentItem.mark.place.locality || mostRecentItem.mark.place.sublocality || mostRecentItem.mark.place.subregion || mostRecentItem.mark.place.region || mostRecentItem.mark.place.country
        macro = mostRecentItem.mark.place.region || mostRecentItem.mark.place.country unless locale == mostRecentItem.mark.place.region || locale == mostRecentItem.mark.place.country
        return { name: locale, lat: mostRecentItem.mark.place.lat, lon: mostRecentItem.mark.place.lon, adminName1: macro }

      s.resetList = -> 
        s._setOnScope( [ 'list', 'listQuery', 'nearby', 'showMap', 'planNearby', 'planNearbyOptions', 'placeName', 'placeNameOptions', 'placeNearby', 'placeNearbyOptions' ], null )
        s._setOnScope( [ 'items' ], [] )
        $timeout(-> $('#guide').focus() if $('#guide') )
        QueryString.modify({plan: null, near: null, m: null, f: null})

      s.listClass = (mode) -> if mode == 'list' then 'sixteen columns' else 'ten columns'

      s.newList = ( name ) ->
        return unless name?.length
        $('.loading-mask').show()
        $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
        Plan.create( plan_name: name )
          .success (response) ->
            $('.loading-mask').hide()
            list = Plan.generateFromJSON(response)
            s._installList( list )
          .error (response) ->
            $('.loading-mask').hide()
            ErrorReporter.defaultFull( response, 'SinglePagePlans Plan.create', { plan_name: s.listQuery})

      s.setList = (list) -> s._installList( list ) if list

      s._installList = (list) ->
        QueryString.modify({plan: list.id})
        s.setModeViaQueryString()
        s.userOwnsLoadedList = s.currentUserId == list.user_id
        s.plan = s.list = list
        s.lists.unshift(s.list) if s.lists && !_.find( s.lists, (l) -> l.id == s.list.id )
        s.getListItems()
        s.kmlPath = "/api/v1/plans/#{ list.id }/kml"
        s.printPath = "/plans/#{ list.id }/print"

      s.getListItems = ->
        return unless s.list?
        $('.searching-mask').show()
        s.isLoaded = false
        Item.where({ plan_id: s.list.id })
          .success (response) ->
            s.isLoaded = true
            return unless s.list?
            
            s._setOnScope( ['items', 'places'], [] )
            _.forEach response , (item, index) ->
              i = _.extend( Item.generateFromJSON( item ), { index: index, pane: 'list' } )
              s.items.push i

            s._getManifestItems()

            if s.items?.length && !s.nearby
              $timeout(-> s.setNearby( s.bestListNearby(s.items) ) )
            $timeout(-> s.initialSortItems() )
            $timeout(-> s.initializeItemsNotes() )
            $('.searching-mask').hide()
          .error (response) ->
            s.isLoaded = true
            $('.searching-mask').hide()
            ErrorReporter.defaultFull( response, 'SinglePagePlans getListItems', { plan_id: s.list.id })

      s.listOptions = ->
        filter = $filter('filter')
        return [] unless s.lists?.length
        filter(s.lists, s.listQuery)

      s.rename = null
      s.renameList = ->
        if s.userOwnsLoadedList
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
          list.destroy()
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





      # PLACE NEARBY SETTINGS

      s.searchPlaceNearby = -> 
        s.placeNearbyOptions = [] if s.placeNearby?.length
        s._searchPlaceNearbyFunction() if s.placeNearby?.length > 1

      s._searchPlaceNearbyFunction = _.debounce( (-> s._searchPlaceNearby() ), 500 )

      s.placeNearbyOptionSelectable = (option) -> option?.name?.toLowerCase() == s.placeNearby?.split(',')[0]?.toLowerCase()

      s.noPlaceNearbyResults = -> s.placeNearby?.length>1 && s.placeNearbyWorking<1 && s.placeNearbyOptions?.length<1
      s.cleanPlaceNearbyOptions = -> s.placeNearbyOptions = []

      s.placeNearbyWorking = 0
      s._searchPlaceNearby = ->
        return unless s.placeNearby?.length > 1
        s.placeNearbyWorking++
        Geonames.search( s.placeNearby )
          .success (response) ->
            s.placeNearbyWorking--
            s.placeNearbyOptions = response.geonames
            _.map( s.placeNearbyOptions, (o) -> 
              o.lon = o.lng; o.qualifiers = _.uniq( _.compact( [ o.adminName1 unless o.name == o.adminName1, o.countryCode ] ) ).join(", ")
            )
          .error (response) -> 
            s.placeNearbyWorking--
            ErrorReporter.fullSilent(response, 'SinglePagePlaces s.searchPlaceNearby', { query: s.placeName })

      s.setNearBestOption = ->
        return unless s.placeNearbyOptions?.length
        keepGoing = true
        _.forEach( s.placeNearbyOptions, (o) ->
          if s.placeNearbyOptionSelectable(o) && keepGoing
            s.setNearby(o)
            keepGoing = false
        )





      # PLACE SEARCH AND ITEM ADDITION

      s.items = []
      s.itemsFirstLetters = []
      s.itemsTypes = []
      s.itemsRecent = []
      s.itemsLocales = []
      s.sortAscending = true
      s.categoryIs = null

      s.plansNoItems = -> s.lists?.length && !_.uniq( _.flatten( _.map( s.lists, (l) -> l.place_ids ) ) ).length

      s.hasItems = -> s.items?.length > 0

      s.placeNameSearch = -> 
        s.options = [] if s.placeName?.length
        s._placeSearchFunction() if s.placeName?.length > 1 && s.nearby?.lat && s.nearby?.lon

      s._placeSearchFunction = _.debounce( (-> s._makePlaceSearchRequest() ), 500 )

      s.noPlaceNameResults = -> s.placeName?.length>1 && s.placeNameWorking<1 && s.placeNameOptions?.length<1

      s.placeNameWorking = 0
      s._makePlaceSearchRequest = ->
        s.placeNameWorking++
        if s.nearby?.lat?.length && s.nearby?.lon && s.placeName
          Foursquare.search(( "#{s.nearby.lat},#{s.nearby.lon}" ), s.placeName)
            .success (response) ->
              s.placeNameWorking--
              s.placeNameOptions = Place.generateFromJSON(response)
            .error (response) ->
              s.placeNameWorking--
              if response && response.length > 0 && response.match(/failed_geocode: Couldn't geocode param/)?[0]
                Flash.warning("We're having trouble finding '#{s.nearby}'")
                s.nearby = null
              else
                ErrorReporter.fullSilent(response, 'SinglePagePlans s._makeSearchRequest', { near: s.nearby, query: s.placeName }) if response.message != "Insufficient search params"

      s.hasPlaceNameOptions = -> s.placeNameOptions?.length>0

      s.lazyAddItem = -> s.addItem( s.options[0] ) if s.options?.length == 1

      s.addItem = (option) ->
        s.placeNameOptions = []
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





      # NEARBY

      s.setNearby = (nearby) -> 
        return unless nearby?.lat && nearby?.lon && nearby?.name?.length
        s.nearby = nearby
        $timeout(-> $('#place-name').focus() if $('#place-name') )
        QueryString.modify({ near: "#{nearby.name},,#{nearby.lat},#{nearby.lon}" })
        return

      s.nearbyToReset = -> _.compact([ s.nearby?.name, s.nearby?.adminName1, s.nearby?.countryCode ]).join(", ")

      s.resetNearby = -> 
        s._setOnScope( [ 'nearby', 'placeName', 'placeNearby', 'placeOptions', 'centerNearby' ], null )
        $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
        QueryString.modify({ near: null })
        return




      # NOTES

      # NEEDSFOLLOWUP -- Sasha is it better to build a single Database call for ALL ITEMS?
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

      s._searchFunction = _.debounce( (-> s._makeSearchRequest() ), 400 )

      s._makeSearchRequest = ->
        if s.nearby?.length && s.placeName?.length
          Foursquare.search(( s.qsNearby || s.nearby ), s.placeName)
            .success (response) ->
              s.options = Place.generateFromJSON Foursquare.parse(response)
            .error (response) ->
              if response && response.length > 0 && response.match(/failed_geocode: Couldn't geocode param/)?[0]
                Flash.warning("We're having trouble finding '#{s.nearby}'")
                s.forbiddenNearby.push s.nearby unless s.nearby == null
                s.nearby = null
                s.qsNearby = null
              else
                ErrorReporter.fullSilent(response, 'SinglePagePlans s._makeSearchRequest', { near: s.nearby, query: s.placeName }) if response.message != "Insufficient search params"

      s.hasOptions = -> s.options?.length>0

      s.addItem = (option) ->
        s.options = []
        s.placeName = null

        s.list.addItemFromPlaceData(option)
          .success (response) ->
            Flash.success("#{response.mark?.place?.names?[0]} added to your list")
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




      # DRAG-DROP

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




      # ITEM CONTROLS

      s.fsOpen = (item, doIt) ->
        return unless doIt and item.placeHref()
        window.open(item.placeHref(), '_blank')
        return

      s.deleteItem = (item) ->
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