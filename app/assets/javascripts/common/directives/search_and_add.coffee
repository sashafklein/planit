angular.module("Common").directive 'searchAndAdd', (Mark, Place, $timeout, ErrorReporter, $sce, CurrentUser, Modal) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "search_and_add.html"
    scope:
      addOnly: '@'
      hideSearch: '&'

    link: (s, element) ->

      s.currentPlaceId = 0 
      s.typing = false
      s.userId = CurrentUser.id
      s.splitKey = "near"

      # BAR VISUALS

      s.clearSearch = ->
        s.query = s.queryOnly = s.places = s.nearby = s.makingRequest = s.overrideSplit = null
        s.splitKey = "nearby"

      s.showResults = -> !s.typing && ( s.query?.length || s.places?.length )

      # SEARCH GUTS

      s._makeSearchRequest = ->
        return if s.makingRequest || !(s.query || s.queryOnly)
        s.makingRequest = true
        Place.search( (s.queryOnly || s.query), (s.nearby || null) )
          .success (response) ->
            s.places = Place.generateFromJSON(response)
            _.forEach(s.places, (p, k) -> _.extend(p, { viewId: k + 1} ) )
            s.makingRequest = false
          .error (response) ->
            s.makingRequest = false

      s.handleKeydown = (event) ->
        if _.contains([13, 40, 38, 91, 18, 17, 9], event.keyCode)
          event.preventDefault() unless event.keyCode
          switch event.keyCode
            when 13 then s._goTo(s.currentPlaceId) # enter
            when 40 then s.togglePosition(1) # down arrow
            when 38 then s.togglePosition(-1) # up arrow
            when 9 then  s._focusOnNearby() # tab
        else if event.keyCode == 8 # backspace
          if s.queryOnly && !s.nearby?.length
            s._unSplit('')            
          else
            s._checkNearbySplit()
            s._calcNearbySplit() 
            s.clearSearch() if !s.query?.length
        else
          s.typing = true unless s.typing
        return true

      s._turnOffTyping = _.debounce( (=> s.$apply(s.typing = false)), 300)
      s.handleKeyup = (event) -> 
        if event.keyCode == 32 # space
          s._checkNearbySplit()
          s._calcNearbySplit() 
        s._turnOffTyping()
        window.searchquery = { q:(s.queryOnly||s.query), n:s.nearby }

      s._spacedBefore = (phrase) -> if phrase && phrase.length then " " + phrase else ''
        
      s._unSplit = () ->
        s.query = s.queryOnly + " " + s.splitTerm.replace(" ","").replace(" ","") + s._spacedBefore(s.nearby)
        s.queryOnly = s.splitTerm = s.nearby = null
        $timeout(-> $(".search-bar-wrap input#primary").focus() if $(".search-bar-wrap input#primary") )
        return true

      s._calcNearbySplit = ->
        if s.splitTerm
          s._executeSplit( s.query.split(s.splitTerm) ) if !s.queryOnly
        return true

      s._executeSplit = (split) ->
        s.queryOnly = split[0]
        s.nearby ||= split[1]
        $timeout(-> $(".search-bar-wrap input#secondary").focus() if $(".search-bar-wrap input#secondary") )
        return true

      s._checkNearbySplit = ->
        s.typing = true unless s.typing
        splitTerms = [ ' in ', ' near ', ' nearby ', ' around ', ' @ ', ", near: ", ", " ].join('|') if !s.overrideSplit
        splitTerms = " #{s.splitKey} " if s.overrideSplit
        splitTerm = s.query.match(new RegExp(splitTerms)) unless !s.query
        s.splitTerm = splitTerm[0] if splitTerm?.length # first split term used
        return true

      s.overrideSplit = false

      s.forceUnSplit = ->
        s.overrideSplit = true
        s.splitKey = ", near:"
        s._unSplit()

      s.togglePosition = (num) ->
        return s.currentPlaceId = 0 unless s.places?.length
        position = (s.currentPlaceId + num) %% s.places.length
        s.currentPlaceId = if position == 0 then s.places.length else position

      s.selectPlace = (place) -> s.currentPlaceId = place.viewId
      s.deselectPlace = -> s.currentPlaceId = 0

      s._searchFunction = _.debounce( (-> s.$apply( s._makeSearchRequest() ) ), 300 )
      s.search = -> s._searchFunction()

      s._goTo = (viewId) ->
        if s.places?.length
          place = _.find(s.places, (p) -> p.viewId == viewId)
          window.location.href = "/places/#{place.id}" if place
        else if s.canCreatePlace()
          s.createPlace()

      # EXISTING MARK?

      s.hasMarkFor = ( place ) -> _.include( place.savers, s.userId )
      s.savedPlace = ( place_id ) -> 
        if place = _.filter( s.places, (p) -> p.id == place_id )[0]
          place.savers.push( s.userId )
      s.removedPlace = ( place_id ) -> 
        if place = _.filter( s.places, (p) -> p.id == place_id )[0]
          place.savers.splice( place.savers.indexOf( s.userId ), 1 )

      # NEW PLACE

      s.canCreatePlace = -> (s.queryOnly?.length || s.query?.length) && s.nearby?.length 

      s.modal = new Modal('addMarkPlace')

      s.createPlace = ->
        return unless s.canCreatePlace() && s.userId
        s.hideSearch()
        s.modal.show({ loading: 'longer' })

        Place.complete({ user_id: s.userId, name: (s.queryOnly || s.query), nearby: s.nearby })
          .success (response) ->
            if $("#planit-modal-new").css("display") != "block" #CANCEL
              markObj = new Mark({ id: response.id })
              markObj.destroy()
                  # .success (response) ->
                  #   #confirm abortion
                .error (response) -> 
                  ErrorReporter.report({ userId: s.userId, nearby: s.nearby, query: (s.queryOnly || s.query), error: response, context: 'Trying to cancel a Mark in search/add mode' })
            else if place = response.place #SUCCESS ONE PLACE
              s.modal.show({ nearby: s.nearby, query: (s.queryOnly || s.query), mark: response })
            else
              new Modal('chooseMarkPlace').show({ nearby: s.nearby, query: (s.queryOnly || s.query), mark: response })
            s.clearSearch()
          .error ->
            s.modal.show({ error: true })
            ErrorReporter.report({ userId: s.userId, nearby: s.nearby, query: (s.queryOnly || s.query) })
            s.clearSearch()

  }