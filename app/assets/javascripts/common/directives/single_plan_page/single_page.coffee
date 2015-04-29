angular.module("Common").directive 'singlePage', (User, Plan, Mark, Item, Place, Note, Foursquare, QueryString, Geonames, CurrentUser, ErrorReporter, Flash, $filter, $timeout, $location, $q) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single_page.html'

    link: (s, e, a) ->
      # Master object passed between sub-directives
      s.m = {}
      s.m._setValues = (object, list, value = null) -> _.forEach list, (i) -> object[i] = ( if value? then _.clone(value) else null )

      s.m.currentUser = CurrentUser
      s.m.currentUserId = s.m.currentUser.id
      s.m.currentUserName = s.m.currentUser.name
      s.m.currentUserFirstName = s.m.currentUser.firstName
      s.m.currentUserIsActive = _.contains(['admin', 'member'], s.m.currentUser.role)

      s.m.mobile = e.width() < 768
      # s.bestPageTitle = -> if s.list then s.list.name else "#{s.currentUserName}'s Planit"
    
      s.m.list = null
      s.m.plan = null

      s.m.hasLists = -> s.m.lists?.length > 0
      s.m.hasItems = -> s.m.items?.length > 0

      # EXPAND/CONTRACT

      s.m.mainMenuToggled = false

      s.m.setModeViaQueryString = ->
        if mode_in_querystring = QueryString.get()['mode']
          s.m.mode = mode_in_querystring
          if s.m.mode == 'map' then s.m.showMap = true else s.m.showMap = false
        else
          s.m.mode = 'list'
          QueryString.modify({mode: 'list'})

      s.m.handleKeyup = -> s.m._turnOffTyping()
      s.m.handleKeydown = -> s.m.typing = true unless s.m.typing
      s.m._turnOffTyping = _.debounce( (=> s.$apply(s.m.typing = false)), 300)

      s.m.items = []
      s.m.itemsFirstLetters = []
      s.m.itemsTypes = []
      s.m.itemsRecent = []
      s.m.itemsLocales = []
      s.m.sortAscending = true
      s.m.categoryIs = null
      s.m.addBoxToggled = true

      s.m.newList = ( name ) ->
        return unless name?.length
        $('.loading-mask').show()
        $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
        Plan.create( plan_name: name )
          .success (response) ->
            $('.loading-mask').hide()
            list = Plan.generateFromJSON(response)
            s.m._installList( list )
          .error (response) ->
            $('.loading-mask').hide()
            ErrorReporter.defaultFull( response, 'SinglePagePlans Plan.create', { plan_name: s.listQuery})

      s.m.initialSortItems = -> s.m.setCategoryAs('type')

      s.m.sortItems = ->
        return unless s.m.items
        s.m.itemsTypes = _.sortBy( _.uniq( _.map( s.m.items, (i) -> i.mark.place.meta_categories[0] ) ) , (i) -> return i )
        s.m.itemsTypes = s.m.itemsTypes.reverse() unless s.sortAscending
        s.itemsFirstLetters = _.sortBy( _.uniq( _.compact( _.map( s.m.items, (i) -> i.mark.place.names?[0]?[0] ) ) ) , (i) -> return i )
        s.itemsFirstLetters = s.itemsFirstLetters.reverse() unless s.sortAscending
        s.itemsRecent = _.sortBy( _.uniq( _.map( s.m.items, (i) -> x=i.updated_at.match(/(\d{4})-(\d{2})-(\d{2})/); return "#{x[2]}/#{x[3]}/#{x[1]}" ) ) , (i) -> return i )
        s.itemsRecent = s.itemsRecent.reverse() unless s.sortAscending
        s.itemsLocales = _.sortBy( _.uniq( _.map( s.m.items, (i) -> i.mark.place.locality ) ) , (i) -> return i )
        s.itemsLocales = s.itemsLocales.reverse() unless s.sortAscending
        s.buildCategories()

      s.m.setCategoryAs = ( choice ) -> 
        if choice == s.m.categoryIs then s.sortAscending = !s.sortAscending else s.m.categoryIs = choice
        s.m.sortItems()

      s.m.setList = (list) -> s.m._installList( list ) if list

      s.m._installList = (list) ->
        QueryString.modify({plan: list.id})
        s.m.setModeViaQueryString()
        s.m.userOwnsLoadedList = s.m.currentUserId == list.user_id
        s.m.plan = s.m.list = list
        s.m.lists.unshift(s.m.list) if s.m.lists && !_.find( s.m.lists, (l) -> l.id == s.m.list.id )
        s.getListItems()
        s.m.kmlPath = "/api/v1/plans/#{ list.id }/kml"
        s.m.printPath = "/plans/#{ list.id }/print"

      s.m.settingsBoxToggle = -> s.m.settingsBoxToggled = !s.m.settingsBoxToggled

      # QUERYSTRING MANAGE START DATA

      if plan_id = QueryString.get()['plan']
        Plan.find(plan_id)
          .success (response) ->
            s.m.list = s.m.plan = Plan.generateFromJSON( response )
            s.m.setList( s.m.list )
            if locale = QueryString.get()['near']
              nameAndLatLon = locale.split(',,')
              if nameAndLatLon?.length == 2
                name = nameAndLatLon[0]
                latLon = nameAndLatLon[1].split(',')
                if latLon?.length == 2
                  s.m.nearby = { name: name, lat: latLon[0], lon: latLon[1] }
            # else if mapCenter = QueryString.get()['m']
            #   s.m.nearbyFromMapCenter( mapCenter )

          .error (response) ->
            QueryString.modify({plan: null, near: null})
            ErrorReporter.defaultFull( response, "SinglePagePlans top Plan.find", { plan_id: plan_id } )



      # VALIDATE LOCATION AND START LIST

      # s.m.nearbyFromMapCenter = (mapCenter) ->
      #   return unless mapCenter?.length
      #   mapCenterSplit = mapCenter?.split(',')
      #   return unless mapCenterSplit && mapCenterSplit?.length > 1
      #   if s.qsNearby || ( !s.m.nearby?.length && !s.placeNearby?.length )
      #     lat = parseFloat( mapCenterSplit[0] )
      #     lon = parseFloat( mapCenterSplit[1] )
      #     s.qsNearby = "#{lat},#{lon}"
      #     geonamesQuery = "https://api.geonames.org/citiesJSON?north=#{ lat + 0.0075 }&south=#{ lat - 0.0075 }&east=#{ lon + 0.0125 }&west=#{ lon - 0.0125 }&username=planit&lang=en&style=full&callback=JSON_CALLBACK"
      #     $http.jsonp(geonamesQuery)
      #       .success (response) -> 
      #         cities = _.filter( response.geonames, (n) -> n.fclName == "city, village,..." )
      #         return unless cities[0]
      #         if s.qsNearby || ( !s.m.nearby?.length && !s.placeNearby?.length )
      #           s.m.nearby = "#{cities[0].name}" 
      #           s.qsNearby = "#{lat},#{lon}"
      #       .error (response) -> ErrorReporter("Geonames Cities Query not working on SinglePagePlan")




      # LISTS & SETTING LISTS

      s.getUsersLists = ->
        if s.m.currentUserId
          User.findPlans( s.m.currentUserId )
            .success (response) ->
              unsortedLists = Plan.generateFromJSON(response)
              s.m.lists = _.sortBy( unsortedLists, (l) -> s.bestListDate(l) ).reverse()
              s.m.isLoaded = true unless s.m.list
            .error (response) ->
              ErrorReporter.defaultFull( response, 'SinglePagePlans getUsersLists' )
              s.m.isLoaded = true 

      s.bestListDate = (list) -> if list.starts_at then list.starts_at else list.updated_at

      s.bestListNearby = (items) -> 
        return unless items?.length && items[0]?.mark?.place
        mostRecentItem = _.sortBy( items, (i) -> i.updated_at ).reverse()[0]
        locale = mostRecentItem.mark.place.locality || mostRecentItem.mark.place.sublocality || mostRecentItem.mark.place.subregion || mostRecentItem.mark.place.region || mostRecentItem.mark.place.country
        macro = mostRecentItem.mark.place.region || mostRecentItem.mark.place.country unless locale == mostRecentItem.mark.place.region || locale == mostRecentItem.mark.place.country
        return { name: locale, lat: mostRecentItem.mark.place.lat, lon: mostRecentItem.mark.place.lon, adminName1: macro }

      s.m.resetList = -> 
        s.m._setValues( s.m, [ 'list', 'nearby', 'settingsBoxToggled', 'showMap' ], null )
        s.m._setValues( s.m, [ 'items' ], [] )
        s.m._setValues( s, ['listQuery', 'planNearby', 'planNearbyOptions', 'placeName', 'placeNameOptions', 'placeNearby', 'placeNearbyOptions'], null)
        $timeout(-> $('#guide').focus() if $('#guide') )
        QueryString.modify({plan: null, near: null, m: null, f: null})

      s.getListItems = ->
        return unless s.m.list?
        $('.searching-mask').show()
        s.m.isLoaded = false
        Item.where({ plan_id: s.m.list.id })
          .success (response) ->
            s.m.isLoaded = true
            return unless s.m.list?
            
            s.m._setValues( s.m, ['items', 'places'], [] )
            _.forEach response , (item, index) ->
              i = _.extend( Item.generateFromJSON( item ), { index: index, pane: 'list' } )
              s.m.items.push i

            # s._getManifestItems()

            if s.m.items?.length && !s.m.nearby
              $timeout(-> s.m.setNearby( s.bestListNearby(s.m.items) ) )
            $timeout(-> s.m.initialSortItems() )
            $timeout(-> s.initializeItemsNotes() )
            $('.searching-mask').hide()
          .error (response) ->
            s.m.isLoaded = true
            $('.searching-mask').hide()
            ErrorReporter.defaultFull( response, 'SinglePagePlans getListItems', { plan_id: s.m.list.id })

      s.listOptions = ->
        filter = $filter('filter')
        return [] unless s.m.lists?.length
        filter(s.m.lists, s.listQuery)

      s.m.deleteList = ( list ) ->
        if confirm("Are you sure you want to delete '#{list.name}'?")
          $('.loading-mask').show()
          list.destroy()
            .success (response) ->
              listIndex = s.m.lists.indexOf( list )
              s.m.lists.splice( listIndex, 1 ) if listIndex > -1
              s.m.resetList() 
              $('.loading-mask').hide()
              return
            .error (response) ->
              ErrorReporter.defaultFull( response, 'SinglePagePlans deleteList', { plan_id: s.m.list.id } )
              $('.loading-mask').hide()
              return

      # NEARBY

      s.m.setNearby = (nearby) -> 
        return unless nearby?.lat && nearby?.lon && nearby?.name?.length
        s.m.nearby = nearby
        s.m.addBoxToggled = true
        $timeout(-> $('#place-name').focus() if $('#place-name') )
        QueryString.modify({ near: "#{nearby.name},,#{nearby.lat},#{nearby.lon}" })
        s.m._setValues( s, ['planNearby', 'planNearbyOptions', 'placeName', 'placeNameOptions', 'placeNearby', 'placeNearbyOptions'], null)
        return




      # NOTES

      s.initializeItemsNotes = -> 
        Note.findAllNotesInPlan( s.m.list.id )
          .success (response) ->
            _.map( s.m.items, (i) -> i.note = _.find( response, (n) -> n.object_id == i.id )?.body; i.notesSearched = true )
          .error (response) ->
            ErrorReporter.defaultFull( response, "singlePagePlans - fetchOriginalNotes", { plan_id: s.m.list.id })
            _.map( s.m.items, (i) -> i.notesSearched = true )





      # LIST SORTING

      s.buildCategories = ->
        s.m.categories = s.m.itemsTypes if s.m.categoryIs == 'type' 
        s.m.categories = s.itemsFirstLetters if s.m.categoryIs == 'alphabetical'
        s.m.categories = s.itemsRecent if s.m.categoryIs == 'recent'
        s.m.categories = s.itemsLocales if s.m.categoryIs == 'locale'        



      # DRAG-DROP

      # s.addToManifest = (item, insertIndex=0) -> 
      #   s._runRequest( ( -> s.m.plan.addToManifest(item, insertIndex) ), 'addToManifest', { item_id: item.id })

      # s.removeFromManifest = (itemIndex) ->
      #   item = s.manifestItems[itemIndex]
      #   s._runRequest( ( -> s.m.plan.removeFromManifest( item, itemIndex ) ), 'removeFromManifest', {item_id: item.id, remove_index: itemIndex} )

      # s.moveInManifest = (from, to) ->
      #   s._runRequest( ( -> s.m.plan.moveInManifest(from, to) ), 'moveInManifest', { from: from, to: to } )

      # s.toggleSelectedItem = (item) -> 
      #   s.selectedItem = (if s.selectedItem == item then null else item)

      # s.isSelected = (item) -> s.selectedItem == item

      # s.hoveringOver = (index) -> 
      #   s.selectedItem? && s.hoverIndex? && s.hoverIndex == index

      # s.setHover = (index) -> s.hoverIndex = index

      # s.insert = () ->
      #   return unless s.selectedItem? && (item = s.selectedItem)
      #   return unless s.hoverIndex?

      #   if item.pane == 'manifest'
      #     s.moveInManifest( item.index, s.hoverIndex )
      #   else
      #     s.addToManifest( item, s.hoverIndex )

      #   s.hoverIndex = s.selectedItem = null

      # s._runRequest = (request, name='', extraReporting={}) ->
      #   request()
      #     .success (response) ->
      #       s._resetManifestItems(response)
      #     .error (response) ->
      #       ErrorReporter.defaultFull response, "singlePagePlans #{name}", _.extend({plan_id: s.m.plan.id}, extraReporting) 

      # s._resetManifestItems = (response) ->
      #   s.m.plan.manifest = response
      #   newManifestItems = []
      #   _.forEach s.m.plan.manifest, (item, index) ->
      #     if found = s._findItem(item)
      #       newManifestItems.push _.extend(found, { $$hashKey: "object:#{index}", index: index, pane: 'manifest' })
      #   s.manifestItems = newManifestItems

      # s._findItem = (manifestItem) -> 
      #   item = _.find(s.items, (i) -> s._identical(i, manifestItem)) || _.find(s.manifestItems, (i) -> s._identical(i, manifestItem) || {})
      #   return null unless item?.class
      #   s._dup(item)

      # s._identical = (i1, i2) -> i1.class == i2.class && i1.id == i2.id

      # s._getManifestItems = ->
      #   s.manifestItems ||= []
      #   _(s.m.plan.manifest).map( (item, index) -> 
      #     ( -> s._getManifestItem( item, index ) )
      #   ).reduce( ( (promise, next) -> promise.then(next) ), $q.when() )

      # s._getManifestItem = (item, index) ->
      #   classObj = s._objectClasses[item.class]
      #   classObj.find(item.id)
      #     .success (response) ->
      #       s.manifestItems.push _.extend( classObj.generateFromJSON(response), { index: index, pane: 'manifest' } )
      #     .error (response) ->
      #       ErrorReporter.defaultFull( response, 'singlePagePlans getManifestItem', { plan_id: s.m.plan.id, item_id: item.id })

      

      s._objectClasses = { "Item": Item }




      # ITEM CONTROLS

      # META / PAGEWIDE

      s._dup = (object) -> s._objectClasses[object.class].generateFromJSON( _.extend({}, object) )
      s.hovering = ( obj ) -> s.hoveredId = obj.id
      s.unhovering = -> s.hoveredId = null



      # INITIALIZE

      s.getUsersLists()
      $timeout(-> $('#guide').focus() if $('#guide') ) unless s.m.list

      window.s = s
    }