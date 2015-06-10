angular.module("Directives").directive 'singlePage', (User, Plan, Mark, Item, Place, Note, Foursquare, QueryString, Geonames, CurrentUser, ErrorReporter, Flash, $filter, $timeout, $location, $q, RailsEnv, SPUsers, SPPlans, SPLocations, Distance) ->
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

      s.m.userManager = new SPUsers( s.m.currentUserId )
      s.m.users = s.m.userManager.users
      s.m.userInQuestion = -> s.m.userManager.fetch( s.m.userInQuestionId )

      s.trustCircleIds = -> _.map( s.m.userManager.trustCircle( s.m.userInQuestionId ), 'id' )
      s.$watch('trustCircleIds()', (-> s.fetchTrustCirclePlans() ), true)
      s.fetchTrustCirclePlans = -> _.forEach( s.trustCircleIds(), (id) -> s.m.planManager.userPlans( id ) )

      s.m.locationManager = new SPLocations( s.m.currentUserId )
      s.m.locations = s.m.locationManager.locations

      s.m.planManager = new SPPlans( s.m.currentUserId )
      s.m.plans = s.m.planManager.plans
      
      s.m.plan = -> s.m.plans[s.m.currentPlanId]
      s.m.userOwnsPlan = -> s.m.plans[s.m.currentPlanId]?.userOwns()
      # s.m.userCoOwnsPlan = -> s.m.plans[s.m.currentPlanId]?.userCoOwns()
      s.m.sharePlan = ( plan ) -> $('#share-object-id').val( plan.id ); $('#share-object-type').val( 'Plan' ); $('#planit-modal-share').toggle(); return

      s.m.place = -> s.m.placeId

      s.m.browsing = true
      s.m.mobile = e.width() < 768
      s.m.largestScreen = e.width() > 960
      s.m.fullscreen = -> !s.m.plan()

      s.m.categorizeBy = 'type' # MANUALLY SET FOR NOW

      s.m.visitUser = ( user_id ) -> window.location.href = "/users/#{ user_id }"

      # # META-SERVICES
      s.m._setValues = (object, list, value = null) -> _.forEach list, (i) -> object[i] = ( if value? then _.clone(value) else null )
      s.m.hasLength = (hash) -> hash && Object.keys( hash )?.length > 0


      # EXPAND/CONTRACT
      s.m.goHome = -> QueryString.reset()
      s.m.mainMenuToggled = false
      s.m.addBoxToggled = if s.m.mobile then false else true
      s.m.settingsBoxToggle = -> s.m.settingsBoxToggled = !s.m.settingsBoxToggled

      # TYPING
      s.m.handleKeyup = -> s.m._turnOffTyping()
      s.m.handleKeydown = -> s.m.typing = true unless s.m.typing
      s.m._turnOffTyping = _.debounce( (=> s.$apply(s.m.typing = false)), 500)




      # NEARBY SETTING AND SEARCH

      s.m.nearbySearchStrings = []


      # NAVIGATION & PAGE-LOADING

      s.unworking = -> s.m.workingNow = false
      s._hashCommand = -> QueryString.get()
      s._loadFromHashCommand = ->
        hash = s._hashCommand()
        if hash && Object.keys( hash )?.length
          s.m.mode = if hash.mode?.length then hash.mode else 'list'
          if hash.u
            s.m.userInQuestionId = parseInt( hash.u )
          else
            s.m.userInQuestionId = s.m.currentUserId
          if hash.plan
            s.m.planManager.fetchPlan( hash.plan, s.unworking() ) if s.m.plan()?.id != parseInt( hash.plan )
            s.m.currentPlanId = parseInt( hash.plan ) if s.m.currentPlanId != parseInt( hash.plan )
          else
            s.m.currentPlanId = null
        else
          s.m.mode = 'list'
          s.m.currentPlanId = null
          s.m.rename = null
          s.m.userInQuestionId = s.m.currentUserId
        unless hash?.plan
          s.m.isLoaded = true

      s._setBrowserTitle = -> 
        if s.m.plan() && Object.keys( s.m.plan() )?.length
          document.title = "#{s.m.plan().name} : #{s.m.currentUserFirstName}'s Planit"; return
        else
          document.title = "#{s.m.currentUserName}'s Planit"; return


      # INITIALIZE

      s.$watch( '_hashCommand()', (-> s._loadFromHashCommand(); s._setBrowserTitle() ), true )

      window.s = s
  }