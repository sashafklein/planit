angular.module("Common").directive 'printViewController', (Plan, Item, Note, ErrorReporter, QueryString, $timeout, MetaCategory, Plural, CurrentUser) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'print_view_controller.html'
    scope:
      planId: "="

    link: (s, e, a) ->

      s.currentUserOwnsPlan = -> s.plan.user_id == CurrentUser.id
      s.detailLevel = parseInt( QueryString.get()['d'] ) || 2
      s.items = []

      s.changeDetail = ->
        QueryString.modify({ d: s.detailLevel })

      s.getList = ->
        Plan.find( s.planId )
          .success (response) ->
            s.plan = Plan.generateFromJSON( response )
            s.getListItems()
          .error (response) ->
            ErrorReporter.report({ context: "Tried looking up plan number #{s.planId}, unsuccessful"})
      
      s.getListItems = ->
        Item.where({ plan_id: s.planId }, ['hours'])
          .success (response) ->
            _.forEach response , (item, index) ->
              i = _.extend( Item.generateFromJSON( item ), { index: index, pane: 'list' } )
              s.items.push i
            $timeout(-> s.allItems = s.items )
            $timeout(-> s.initializeItemsNotes() )
            $timeout(-> s.initializeLocales() )
          .error (response) ->
            ErrorReporter.report({ context: 'Items.NewCtrl getListItems', list_id: s.list.id}, "Something went wrong! We've been notified.")

      # BY LOCALE

      s.buildAndCompressLocaleList = ( level ) -> 
        levelLocales = _.uniq( _.map( s.items, (i) -> i.mark.place[level] ) )
        # hash = _.map( s.items, (i) -> { locale: i.mark.place[level], lat: i.mark.place.lat, lon: i.mark.place.lon } )
        # combinedHash = {}
        # # _.filter( hash, function(h) { 
        # _.forEach( levelLocales, (l) ->
        #   )

      s.initializeLocales = ->
        localeLevels = ['sublocality', 'locality', 'region', 'country']
        _.forEach localeLevels, (level) ->
          s[ "#{level}List" ] = _.compact s.buildAndCompressLocaleList( level )

          if s[ "#{level}List" ]?.length
            s.localeLevel ||= level
            s[ "many#{ Plural.compute(level) }" ] = true

        s.localeLevel ||= _.find( localeLevels, (l) -> _(s.items).map("mark.place.#{l}").uniq().compact().value().length == 1)
        
        s.setLocalesByLevel()

      s.setLocalesByLevel = -> s.locales = s[ "#{s.localeLevel}List" ]

      s.localeItems = ( locale ) -> _.filter( s.items, (i) -> i.mark.place[ s.localeLevel ] == locale )

      # BY CATEGORY

      s.categories = ( items ) -> _.uniq( _.map( items, (i) -> i.meta_category ) )
      s.categoryItems = ( meta_category, items ) -> 
        _( items ).filter( 
          (i) -> i.meta_category == meta_category 
        ).sortBy( (i) -> String( i.symbol ) ).value()

      # GET NOTES

      s.initializeItemsNotes = -> _.map( s.items, (item) -> s.fetchOriginalNote(item) )
      s.fetchOriginalNote = (item) ->
        Note.findByObject( item )
          .success (response) ->
            if note = response.body then s.items[s.items.indexOf(item)].note = note
            $timeout(-> s.isLoaded = true )
          .error (response) ->
            ErrorReporter.report({ context: "Failed note fetch in list page", obj_id: item.id, obj_type: item.class })
            $timeout(-> s.isLoaded = true )

      # ITEM FEATURES

      s.metaClass = ( meta_category ) -> MetaCategory.colorClass(meta_category)

      s.hasCategories = (item) -> item.mark.place.categories.length

      s.zoom = 16
      s.staticMap = (item) -> "http://staticmap.openstreetmap.de/staticmap.php?center=#{ s.coord(item) }&zoom=#{ s.zoom }&size=130x130&maptype=osmarenderer"
      s.directionsLink = (item) -> "https://maps.google.com?daddr=#{ s.coord(item) }"
      s.coord = (item) -> "#{item.mark.place.lat},#{item.mark.place.lon}"

      s.hasNote = (item) -> item?.note?.length

      s.hours = (item, day) -> 
        return null unless day && day_hours = item.mark.place.hours[ day ]
        hour_windows = _.map day_hours, (hour_window) -> "#{hour_window.first} - #{hour_window.last}"
        # "#{Time.strptime(hour_window.first, '%H%M').strftime('%l:%M%p').downcase} - #{Time.strptime(hour_window.last, '%H%M').strftime('%l:%M%p').downcase}"

        return "<span class='day-name'>#{ day }</span>: #{ hour_windows.join(', ') }".html_safe
        # return Su Mo Tu We Th Fr Sa colored

      # OTHER

      s.printNow = -> window.print()

      s.getList()

      window.controller = s
  }