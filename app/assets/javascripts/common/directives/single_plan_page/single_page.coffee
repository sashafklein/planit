angular.module("Common").directive 'singlePage', (User, Plan, Mark, Item, Place, Note, Foursquare, QueryString, Geonames, CurrentUser, ErrorReporter, Flash, $filter, $timeout, $location, $q, RailsEnv, SPPlans) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single_page.html'

    link: (s, e, a) ->

      # MASTER OBJECT PASSED BETWEEN PAGES

      s.m = {}

      s.m.currentUser = CurrentUser
      s.m.currentUserId = s.m.currentUser.id
      s.m.currentUserName = s.m.currentUser.name
      s.m.currentUserFirstName = s.m.currentUser.firstName
      s.m.currentUserIsActive = _.contains(['admin', 'member'], s.m.currentUser.role)

      s.m.planManager = new SPPlans( s.m.currentUserId )
      s.m.plans = s.m.planManager.plans
      s.m.plan = -> s.m.plans[s.m.currentPlanId]
      s.m.userOwnsPlan = -> s.m.plans[s.m.currentPlanId]?.userOwns()

      s.m.mobile = e.width() < 768
      s.m.largestScreen = e.width() > 960

      s.m.categorizeBy = 'type' # MANUALLY SET FOR NOW


      # # META-SERVICES
      s.m._setValues = (object, list, value = null) -> _.forEach list, (i) -> object[i] = ( if value? then _.clone(value) else null )


      # EXPAND/CONTRACT
      s.m.goHome = -> QueryString.reset()
      s.m.mainMenuToggled = false
      s.m.addBoxToggled = true
      s.m.settingsBoxToggle = -> s.m.settingsBoxToggled = !s.m.settingsBoxToggled


      # TYPING
      s.m.handleKeyup = -> s.m._turnOffTyping()
      s.m.handleKeydown = -> s.m.typing = true unless s.m.typing
      s.m._turnOffTyping = _.debounce( (=> s.$apply(s.m.typing = false)), 300)


      # LISTS
      s.m.hasPlans = -> Object.keys( s.m.plans )?.length > 0


      # NEARBY SETTING AND LOOKUP

      s.m.nearbyOptions = []

      s.m.setNearby = ( nearby ) -> 
        s.m._setValues( s.m, ['placeNearby', 'planNearby'], null )
        s.m.nearbyOptions.push( nearby )
        QueryString.modify({ near: nearby.geonameId })

      s._setNearby = ( nearby ) ->
        if nearby && Object.keys( nearby )?.length
          s.m.nearby = nearby
          s.m.addBoxToggled = true
          $timeout(-> $('#place-name').focus() if $('#place-name') )
          s.m._setValues( s, ['planNearby', 'planNearbyOptions', 'placeName', 'placeNameOptions', 'placeNearby', 'placeNearbyOptions'], null)
          return
        else
          s.m._setValues( s, [ 'm.nearby', 'planNearby', 'planNearbyOptions', 'placeName', 'placeNameOptions', 'placeNearby', 'placeNearbyOptions'], null)

      s._nearbyFromQuery = ( geoid ) ->
        return unless s.m.plan() && Object.keys( s.m.plan() )?.length
        if !geoid?.length
          if s.m.plan().items?.length && s.m.plan().items[0]?.mark?.place
            items = s.m.plan().items
            mostRecentItem = _.sortBy( items, (i) -> i.updated_at ).reverse()[0]
            locale = mostRecentItem.mark.place.locality || mostRecentItem.mark.place.sublocality || mostRecentItem.mark.place.subregion || mostRecentItem.mark.place.region || mostRecentItem.mark.place.country
            macro = mostRecentItem.mark.place.region || mostRecentItem.mark.place.country unless locale == mostRecentItem.mark.place.region || locale == mostRecentItem.mark.place.country
            s._setNearby( { name: locale, lat: mostRecentItem.mark.place.lat, lon: mostRecentItem.mark.place.lon, adminName1: macro } )
          else
            s._setNearby( null )
        else
          found = _.find( s.m.nearbyOptions, (o) -> o.geonameId == parseInt( geoid ) )
          if found && Object.keys( found )?.length
            s._setNearby( found )
          else
            Geonames.find( geoid )
              .success (response) -> if response.geonameId == parseInt( geoid ) then s._setNearby( response )
              .error (response) -> s._setNearby( null )


      # NAVIGATION & PAGE-LOADING

      s._hashCommand = -> QueryString.get()

      s._loadFromHashCommand = ->
        hash = s._hashCommand()
        if hash && Object.keys( hash )?.length
          s.m.mode = if hash.mode?.length then hash.mode else 'list'
          s._nearbyFromQuery( hash.near )
          if hash.plan
            s.m.planManager.fetchPlan( hash.plan )
            s.m.currentPlanId = parseInt( hash.plan )
          else
            s.m.currentPlanId = null
        else
          s.m.mode = 'list'
          s.m.nearby = null
          s.m.currentPlanId = null
        unless hash?.plan
          s.m.isLoaded = true

      s._setBrowserTitle = -> 
        if s.m.plan() && Object.keys( s.m.plan() )?.length
          document.title = "#{s.m.plan().name} : #{s.m.currentUserFirstName}'s Planit"; return
        else
          document.title = "#{s.m.currentUserName}'s Planit"; return


      # INITIALIZE

      s.$watch( '_hashCommand()', (-> s._loadFromHashCommand(); s._setBrowserTitle() ), true )

      # # $timeout(-> $('#guide').focus() if $('#guide') ) unless s.m.currentListId

      window.s = s
  }