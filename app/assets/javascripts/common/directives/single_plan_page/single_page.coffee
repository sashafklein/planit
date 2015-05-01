  angular.module("Common").directive 'singlePage', (User, Plan, Mark, Item, Place, Note, Foursquare, QueryString, Geonames, CurrentUser, ErrorReporter, Flash, $filter, $timeout, $location, $q, RailsEnv, SPLists, SPList, SPItem) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single_page.html'

    link: (s, e, a) ->

      # Master object passed between sub-directives

      s.m = {}

      s.m.pusher = new Pusher( RailsEnv.pusher_key )
      s.m.currentUser = CurrentUser
      s.m.currentUserId = s.m.currentUser.id
      s.m.currentUserName = s.m.currentUser.name
      s.m.currentUserFirstName = s.m.currentUser.firstName
      s.m.currentUserIsActive = _.contains(['admin', 'member'], s.m.currentUser.role)

      s.m.lists = new SPLists( s.m.currentUserId )

      # s.m.mobile = e.width() < 768
      # s.m.largestScreen = e.width() > 960
      # # s.bestPageTitle = -> if s.list then s.list.name else "#{s.currentUserName}'s Planit"

      # s.m.nearbyOptions = []

      # s.m.hasItems = -> s.m.list()?.items?.length > 0


      # # META-SERVICES
      # s.m._setValues = (object, list, value = null) -> _.forEach list, (i) -> object[i] = ( if value? then _.clone(value) else null )


      # # EXPAND/CONTRACT
      # s.m.mainMenuToggled = false
      # s.m.addBoxToggled = true
      # s.m.settingsBoxToggle = -> s.m.settingsBoxToggled = !s.m.settingsBoxToggled


      # # TYPING
      # s.m.handleKeyup = -> s.m._turnOffTyping()
      # s.m.handleKeydown = -> s.m.typing = true unless s.m.typing
      # s.m._turnOffTyping = _.debounce( (=> s.$apply(s.m.typing = false)), 300)


      # # LISTS
      # s.m.hasLists = -> s.m.lists?.length > 0


      # # LIST
      # s.m.setList = ( list ) -> QueryString.modify({ plan: list.id })
      # s.m.list = -> _.find( s.m.lists, (l) -> parseInt( l.id ) == parseInt( s.m.currentListId ) )
      # s.m.userOwnsLoadedList = -> parseInt( s.m.list()?.user_id ) == currentUserId
      # s.m.kmlPath = -> "/api/v1/plans/#{ s.m.currentListId }/kml" unless !s.m.currentListId?.length
      # s.m.printPath = -> "/plans/#{ s.m.currentListId }/print" unless !s.m.currentListId?.length
      # s.m.resetList = -> QueryString.modify({plan: null, near: null, m: null, f: null}); $timeout(-> $('#guide').focus() if $('#guide') ); return



      # # s.bestListNearby = (items) -> 
      # #   return unless items?.length && items[0]?.mark?.place
      # #   return unless !s.m.nearby
      # #   mostRecentItem = _.sortBy( items, (i) -> i.updated_at ).reverse()[0]
      # #   locale = mostRecentItem.mark.place.locality || mostRecentItem.mark.place.sublocality || mostRecentItem.mark.place.subregion || mostRecentItem.mark.place.region || mostRecentItem.mark.place.country
      # #   macro = mostRecentItem.mark.place.region || mostRecentItem.mark.place.country unless locale == mostRecentItem.mark.place.region || locale == mostRecentItem.mark.place.country
      # #   return { name: locale, lat: mostRecentItem.mark.place.lat, lon: mostRecentItem.mark.place.lon, adminName1: macro }


      # # # s.m.isLoaded = false
      # # # s.lists[?].load
      # #       # if s.m.items?.length && !s.m.nearby
      # #       #   $timeout(-> s._setNearby( s.bestListNearby(s.m.items) ) )
      # #       # $timeout(-> s.m.initialSortItems() )


      # # # NEARBY

      # # s.m.setNearby = ( nearby ) -> 
      # #   s.m.placeNearby = null
      # #   s.m.planNearby = null
      # #   s.m.nearbyOptions.push( nearby ); QueryString.modify({ near: nearby.geonameId })

      # # s._setNearby = (nearby) ->
      # #   if nearby && Object.keys( nearby )?.length
      # #     s.m.nearby = nearby
      # #     s.m.addBoxToggled = true
      # #     $timeout(-> $('#place-name').focus() if $('#place-name') )
      # #     s.m._setValues( s, ['planNearby', 'planNearbyOptions', 'placeName', 'placeNameOptions', 'placeNearby', 'placeNearbyOptions'], null)
      # #     return
      # #   else
      # #     s.m._setValues( s, [ 'm.nearby', 'planNearby', 'planNearbyOptions', 'placeName', 'placeNameOptions', 'placeNearby', 'placeNearbyOptions'], null)




      # # # LIST SORTING

      # # s.buildCategories = ->
      # #   s.m.categories = s.m.itemsTypes if s.m.categoryIs == 'type' 
      # #   s.m.categories = s.itemsFirstLetters if s.m.categoryIs == 'alphabetical'
      # #   s.m.categories = s.itemsRecent if s.m.categoryIs == 'recent'
      # #   s.m.categories = s.itemsLocales if s.m.categoryIs == 'locale'        




      # s.hovering = ( obj ) -> s.hoveredId = obj.id
      # s.unhovering = -> s.hoveredId = null




      # # NAVIGATION & PAGE-LOADING

      # s._hashCommand = -> QueryString.get()

      # s._loadFromHashCommand = ->
      #   hash = s._QShash()
      #   if hash && Object.keys( hash )?.length
      #     s.m.mode = if hash.mode?.length then hash.mode else 'list'
      #     s.m.showMap = if s.m.mode == 'map' then true else s.m.showMap = false
      #     # s._nearbyFromQuery( hash.near )
      #     s.m.currentListId = if hash.plan?.length then hash.plan else null
      #   else
      #     s.m.mode = 'list'
      #     s.m.showMap = false
      #     s.m.nearby = null
      #     s.m.currentListId = null
      #   unless hash?.plan
      #     s.m.isLoaded = true 

      # # s._nearbyFromQuery = ( geoid ) -> 
      # #   if !geoid?.length
      # #     s._setNearby( null )
      # #   else
      # #     found = _.find( s.m.nearbyOptions, (o) -> o.geonameId == parseInt( geoid ) )
      # #     if found && Object.keys( found )?.length
      # #       s._setNearby( found )
      # #     else
      # #       Geonames.find( geoid )
      # #         .success (response) -> if response.geonameId == parseInt( geoid ) then s._setNearby( response )
      # #         .error (response) -> s._setNearby( null )

      # # INITIALIZE

      # s.$watch( '_hashCommand()', (-> s._loadFromHashCommand() ), true )

      # # $timeout(-> $('#guide').focus() if $('#guide') ) unless s.m.currentListId

      window.s = s
    }