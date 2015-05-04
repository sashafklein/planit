angular.module("Common").directive 'printViewController', (Plan, Item, Note, ErrorReporter, QueryString, $timeout) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'print_view_controller.html'
    scope:
      planId: "="

    link: (s, e, a) ->

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
          s[ "#{level}List" ] = s.buildAndCompressLocaleList( level )

          if s[ "#{level}List" ]?.length
            s.localeLevel = level
            s[ "many#{ s._pluralize(level) }" ] = true

        s.localeLevel ||= _.find( localeLevels, (l) -> _(s.items).map("mark.place.#{l}").uniq().compact().value().length == 1)
        
        s.setLocalesByLevel()

      s._pluralize = (level) ->
        switch level
          when 'country' then 'countries'
          when 'region' then 'regions'
          when 'locality' then 'localities'
          when 'sublocality' then 'sublocalities'
          else level + 's'

      s.setLocalesByLevel = ->
        if s.localeLevel == 'sublocality' then s.locales = s.sublocalityList
        if s.localeLevel == 'locality' then s.locales = s.localityList
        if s.localeLevel == 'region' then s.locales = s.regionList
        if s.localeLevel == 'country' then s.locales = s.countryList

      s.localeItems = ( locale ) ->
        itemsInLocale = []
        if s.localeLevel == 'sublocality' then itemsInLocale = _.filter( s.items, (i) -> i.mark.place.sublocality == locale )
        if s.localeLevel == 'locality' then itemsInLocale = _.filter( s.items, (i) -> i.mark.place.locality == locale )
        if s.localeLevel == 'region' then itemsInLocale = _.filter( s.items, (i) -> i.mark.place.region == locale )
        if s.localeLevel == 'country' then itemsInLocale = _.filter( s.items, (i) -> i.mark.place.country == locale )
        return itemsInLocale

      # BY CATEGORY

      s.categories = ( items ) -> _.uniq( _.map( items, (i) -> i.mark.place.meta_categories[0] ) )
      s.categoryItems = ( meta_category, items ) -> _.filter( items, (i) -> i.mark.place.meta_categories[0] == meta_category )

      # GET NOTES

      s.initializeItemsNotes = -> _.map( s.items, (item) -> s.fetchOriginalNote(item) )
      s.fetchOriginalNote = (item) ->
        Note.findByObject( item )
          .success (response) ->
            if note = response.body then s.items[s.items.indexOf(item)].note = note
            $timeout(-> s.isLoaded = true )
          .error (response) ->
            ErrorReporter.report({ context: "Failed note fetch in list page", object_id: item.id, object_type: item.class })
            $timeout(-> s.isLoaded = true )

      # ITEM FEATURES

      s.metaClass = ( meta_category ) -> 
        colorClass = 'yellow' if meta_category == 'Area'
        colorClass = 'green' if meta_category == 'See'
        colorClass = 'bluegreen' if meta_category == 'Do'
        colorClass = 'turqoise' if meta_category == 'Relax'
        colorClass = 'blue' if meta_category == 'Stay'
        colorClass = 'purple' if meta_category == 'Drink'
        colorClass = 'magenta' if meta_category == 'Food'
        colorClass = 'pink' if meta_category == 'Shop'
        colorClass = 'orange' if meta_category == 'Help'
        colorClass = 'gray' if meta_category == 'Other'
        colorClass = 'gray' if meta_category == 'Transit'
        colorClass = 'gray' if meta_category == 'Money'
        return colorClass

      s.hasCategories = (item) -> item.mark.place.categories.length

      s.zoom = 15
      s.staticMap = (item) -> "http://staticmap.openstreetmap.de/staticmap.php?center=#{ s.coord(item) }&zoom=#{ s.zoom }&size=130x130&maptype=osmarenderer"
      s.directionsLink = (item) -> "https://maps.google.com?daddr=#{ s.coord(item) }"
      s.coord = (item) -> "#{item.mark.place.lat},#{item.mark.place.lon}"

      s.hasNote = (item) -> item?.note?.length

      s.hours = (item, day) -> 
        if day
          if day_hours = item.mark.place.hours[ day ]
            hour_windows = []
            _.forEach( day_hours, (hour_window) ->
              hour_windows.push "#{hour_window.first} - #{hour_window.last}"
              # hour_windows.push "#{Time.strptime(hour_window.first, '%H%M').strftime('%l:%M%p').downcase} - #{Time.strptime(hour_window.last, '%H%M').strftime('%l:%M%p').downcase}"
            )
            return "<span class='day-name'>#{ day }</span>: #{ hour_windows.join(', ') }".html_safe
        else
          # return Su Mo Tu We Th Fr Sa colored
          null

      # OTHER

      s.printNow = -> window.print()

      s.getList()

      window.controller = s
  }