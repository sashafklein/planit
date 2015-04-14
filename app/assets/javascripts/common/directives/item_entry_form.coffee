angular.module("Common").directive 'itemEntryForm', (User, Plan, Item, Place, Foursquare, ErrorReporter, CurrentUser, QueryString, $filter, $timeout, $event) ->
  return {
    restrict: 'E'
    templateUrl: 'item_entry_form.html'

    link: (s, e, a) ->


      # QUERYSTRING MANAGE START DATA

      if plan_id = QueryString.get()['plan']
        Plan.find(plan_id)
          .success (response) ->
            s.list = Plan.generateFromJSON( response )
            s.setList( s.list )
            if locale = QueryString.get()['near']
              s.nearby = locale
          .error (response) ->
            QueryString.modify({plan: null, near: null})
            ErrorReporter.report({ context: 'Tried looking up #{plan_id} plan, unsuccessful'})
      else
        # QueryString.reset()


      # LISTS & SETTING LISTS

      s.forbiddenNearby = []

      s.getUsersLists = ->
        User.findPlans( CurrentUser.id )
          .success (response) ->
            s.lists = Plan.generateFromJSON(response)
          .error (response) ->
            ErrorReporter.report({ context: 'Items.NewCtrl getUsersLists'}, "Something went wrong! We've been notified.")

      s.setListOnEnter = ->
        if s.listOptions().length == 1
          s.setList( s.listOptions()[0] ) 
        else
          s.setList()

      s.resetList = ->
        s.list = s.listQuery = s.options = s.placeName = s.placeNearby = s.nearby = null
        $timeout(-> $('#guide').focus() if $('#guide') )
        s.items = []
        QueryString.modify({plan: null, near: null})

      s.canAddList = -> s.listQuery?.length > 2 && ( !s.lists?.length || !s.listOptions()?.length || ( s.listOptions()?.length > 0 && !s.optionMatchesListQuery() ) )

      s.setList = (list) ->
        if list
          $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
          s._installList(list)
          QueryString.modify({plan: list.id})
        else if list = s.optionMatchesListQuery()
          $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
          s._installList( list )
          QueryString.modify({plan: list.id})
        else if s.canAddList
          if confirm("Create a new guide named '#{s.listQuery}'?")
            $('.loading-mask').show()
            $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
            Plan.create( plan_name: s.listQuery )
              .success (response) ->
                $('.loading-mask').hide()
                list = Plan.generateFromJSON(response)
                s._installList list
                QueryString.modify({plan: list.id})
              .error (response) ->
                $('.loading-mask').hide()
                ErrorReporter.report({ context: 'Items.NewCtrl Plan.create', plan_name: s.listQuery}, "Something went wrong! We've been notified.")

      s._installList = (list) ->
        s.list = list
        s.getListsItems()
        s.listQuery = list.name

      s.getListsItems = ->
        return unless s.list?
        $('.searching-mask').show()
        Item.where({ plan_id: s.list.id })
          .success (response) ->
            $('.searching-mask').hide()
            return unless s.list?
            s.items = Item.generateFromJSON( response )
            s.initialSortItems()
          .error (response) ->
            $('.searching-mask').hide()
            ErrorReporter.report({ context: 'Items.NewCtrl getListsItems', list_id: s.list.id}, "Something went wrong! We've been notified.")

      s.listOptions = ->
        filter = $filter('filter')
        return [] unless s.lists?.length
        filter(s.lists, s.listQuery)

      s.optionMatchesListQuery = -> _(s.listOptions()).find( (o) -> o.name.toLowerCase() == s.listQuery.toLowerCase() )

      s.rename = null
      s.renameList = ->
        s.rename = s.list.name
        # $('.everything-but-mask').show()
        # $('.above-mask').css('z-index', '200000000')
        $timeout(-> $('#rename').focus() if $('#rename') )
        return
      s.saveRenameList = -> 
        s.list.update({ plan: { name: s.rename } })
          .success (response) ->
            s.list = Plan.generateFromJSON( response )
            s.cancelRenameList()
          .error (response) ->
            s.cancelRenameList()
            ErrorReporter.report({ context: 'Failed to rename plan', list_id: s.list.id})
      s.cancelRenameList = ->
        s.rename = null
        # $('.everything-but-mask').hide()
        return



      # ITEMS == SEARCH, ADD

      s.items = []
      s.itemsFirstLetters = []
      s.itemsTypes = []
      s.itemsRecent = []
      s.itemsLocales = []
      s.sortAscending = true
      s.categoryIs = null

      s.canSetNearby = (nearby) -> nearby?.length > 2 && !_(s.forbiddenNearby).find( (o) -> o.toLowerCase() == nearby?.toLowerCase() )      
      s.setNearby = (nearby) -> 
        s.nearby = nearby if s.canSetNearby(nearby)
        $timeout(-> $('#place-name').focus() if $('#place-name') )
        QueryString.modify({ near: nearby })
        return

      s.resetNearby = -> 
        s.nearby = null
        $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
        QueryString.modify({ near: null })
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

      s.initialSortItems = -> s.setCategoryAs('type')

      s.sortItems = ->
        return unless s.items
        s.itemsTypes = _.sortBy( _.uniq( _.compact( _.map( s.items, (i) -> i.mark.place.meta_categories[0] ) ) ) , (i) -> return i )
        s.itemsTypes = s.itemsTypes.reverse() unless s.sortAscending
        s.itemsFirstLetters = _.sortBy( _.uniq( _.compact( _.map( s.items, (i) -> i.mark.place.names[0][0] ) ) ) , (i) -> return i )
        s.itemsFirstLetters = s.itemsFirstLetters.reverse() unless s.sortAscending
        # s.itemsRecent = _.sortBy( _.uniq( _.compact( _.map( s.items, (i) -> i.updated_at.strftime('%y%m%d') ) ) ) , (i) -> return i )
        # s.itemsRecent = s.itemsRecent.reverse() unless s.sortAscending
        s.itemsLocales = _.sortBy( _.uniq( _.compact( _.map( s.items, (i) -> i.mark.place.locality ) ) ) , (i) -> return i )
        s.itemsLocales = s.itemsLocales.reverse() unless s.sortAscending

      s.search = -> 
        s.options = [] if s.placeName?.length
        s._searchFunction() if s.placeName?.length > 2 && s.nearby

      s._searchFunction = _.debounce( (-> s._makeSearchRequest() ), 500 )

      s._makeSearchRequest = ->
        Foursquare.search(s.nearby, s.placeName)
          .success (response) ->
            s.options = Place.generateFromJSON(response)
          .error (response) ->
            if response && response.match(/failed_geocode: Couldn't geocode param/)?[0]
              alert("We'll need a better 'Nearby' than '#{s.nearby}'")
              s.forbiddenNearby.push s.nearby
              s.nearby = null
            else
              ErrorReporter.report({ context: 'Items.NewCtrl search', near: s.nearby, query: s.placeName }, "Something went wrong! We've been notified.")        

      s.lazyAddItem = -> s.addItem( s.options[0] ) if s.options?.length == 1

      s.addItem = (option) ->
        $('.searching-mask').show()
        s.options = []
        s.placeName = null
        s.list.addItemFromPlaceData(option)
          .success (response) ->
            $('.searching-mask').hide()
            s.items.unshift Place.generateFromJSON(response) 
            s.sortItems()
          .error (response) ->
            $('.searching-mask').hide()
            ErrorReporter.report({ context: 'Items.NewCtrl addItem', option: JSON.stringify(option), plan: JSON.stringify(s.list) }, "Something went wrong! We've been notified.")        

      s.matchingItems = ( category ) ->
        if s.categoryIs == 'type' then matchingItems = _.filter( s.items, (i) -> i.mark.place.meta_categories?[0] == category )
        if s.categoryIs == 'alphabetical' then matchingItems = _.filter( s.items, (i) -> i.mark.place.names?[0]?[0] == category )
        # if s.categoryIs == 'recent' then matchingItems = _.filter( s.items, (i) -> i.updated_at?.strftime('%y%m%d') == category )
        if s.categoryIs == 'locale' then matchingItems = _.filter( s.items, (i) -> i.mark.place.locality == category )
        return matchingItems

      s.setCategoryAs = ( choice ) -> 
        if choice == s.categoryIs then s.sortAscending = !s.sortAscending else s.categoryIs = choice
        s.sortItems()
        s.categories = s.itemsTypes if choice == 'type' 
        s.categories = s.itemsFirstLetters if choice == 'alphabetical'
        # s.categories = s.itemsRecent if choice == 'recent'
        s.categories = s.itemsLocales if choice == 'locale'

      s.currentNote = (item) ->
        null
        # Note.findByObject( item )
        #   .success (response) ->
        #     this.val(note)
        #   .error (response) ->
        #     ErrorReporter.report({ context: "Failed note addition in list page", object_id: item.id, object_type: 'Item', text: note })
        #     this.val(null)

      s.saveNote = (item) ->
        note = e.find("#item#{item.id}")
        return unless note && note.length > 0
        # Note.create({ note: { object_id: item.id, object_type: 'Item', body: note } })
        #   .success (response) ->
        #     this.val(note)
        #   .error (response) ->
        #     ErrorReporter.report({ context: "Failed note addition in list page", object_id: item.id, object_type: 'Item', text: note })
        #     this.val(null)

      s.nextNote = -> null # on tab

      s.typeIcon = ( category ) ->



      # INITIALIZE

      s.getUsersLists()
      $timeout(-> $('#guide').focus() if $('#guide') ) unless s.list

      window.s = s
    }