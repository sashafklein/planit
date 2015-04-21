angular.module("Common").directive 'printViewController', (Plan, Item, Note, $timeout) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'print_view_controller.html'
    scope:
      planId: "="

    link: (s, e, a) ->

      s.detailLevel = 2
      s.items = []
      # s.places = []

      s.getList = ->
        Plan.find( s.planId )
          .success (response) ->
            s.plan = Plan.generateFromJSON( response )
            s.getListItems()
          .error (response) ->
            QueryString.modify({plan: null, near: null})
            ErrorReporter.report({ context: "Tried looking up #{plan_id} plan, unsuccessful"})
      
      s.getListItems = ->
        Item.where({ plan_id: s.planId })
          .success (response) ->
            _.forEach response , (item, index) ->
              i = _.extend( Item.generateFromJSON( item ), { index: index, pane: 'list' } )
              s.items.push i
              # s.places.push i.mark.place
            # s._getManifestItems()
            $timeout(-> s.initializeItemsNotes() )
            $timeout(-> s.initializeLocales() )
          .error (response) ->
            ErrorReporter.report({ context: 'Items.NewCtrl getListItems', list_id: s.list.id}, "Something went wrong! We've been notified.")

      # BY LOCALE

      s.initializeLocales = ->
        s.sublocalityList = _.uniq( _.map( s.items, (i) -> i.mark.place.sublocality ) )
        s.manySublocalities = if s.sublocalityList?.length > 1 then s.localeLevel = 'sublocality'; true else false
        s.localityList = _.uniq( _.map( s.items, (i) -> i.mark.place.locality ) )
        s.manyLocalities = if s.localityList?.length > 1 then s.localeLevel = 'locality'; true else false
        s.regionList = _.uniq( _.map( s.items, (i) -> i.mark.place.region ) )
        s.manyRegions = if s.regionList?.length > 1 then s.localeLevel = 'region'; true else false
        s.countryList = _.uniq( _.map( s.items, (i) -> i.mark.place.country ) )
        s.manyCountries = if s.countryList?.length > 1 then s.localeLevel = 'country'; true else false
        s.setLocalesByLevel()
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

      s.metaIcon = ( meta_category, items ) -> s.categoryItems( meta_category, items )[0].mark.place.meta_icon
      s.hasCategories = (item) -> item.mark.place.categories.length

      s.zoom = 15
      s.staticMap = (item) -> "http://staticmap.openstreetmap.de/staticmap.php?center=#{ s.coord(item) }&zoom=#{ s.zoom }&size=130x130&maptype=osmarenderer"
      s.directionsLink = (item) -> "https://maps.google.com?daddr=#{ s.coord(item) }"
      s.coord = (item) -> "#{item.mark.place.lat},#{item.mark.place.lon}"

      s.hasNote = (item) -> item?.note?.length

      s.otherNames = (item) -> 
        if item.mark.place.names.length > 1
          item.mark.place.names.shift()
          item.mark.place.names.join(', ')

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