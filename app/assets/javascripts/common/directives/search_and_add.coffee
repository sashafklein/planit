angular.module("Common").directive 'searchAndAdd', (Place, $timeout, ErrorReporter, $sce, CurrentUser, Modal) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "search_and_add.html"
    scope:
      addOnly: '@'

    link: (s, element) ->

      s.currentPlaceId = 0 
      s.typing = false
      s.userId = CurrentUser.id

      # BAR VISUALS

      s.clearSearch = -> s.query = s.places = s.nearby = s.makingRequest = s.overrideSplit = null

      s.showResults = -> !s.typing && ( s.query?.length || s.places?.length )

      # SEARCH GUTS

      s._makeSearchRequest = ->
        return if s.makingRequest
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
        else
          s.typing = true unless s.typing
          s.clearSearch() if !s.query?.length
        console.log( "q:#{s.query},qo:#{s.queryOnly},s:#{s.splitTerm},n:#{s.nearby}" )
        return true

      s._turnOffTyping = _.debounce( (=> s.$apply(s.typing = false)), 300)
      s.handleKeyup = (event) -> 
        s._turnOffTyping()
        s._checkNearbySplit() if _.contains([32, 8, 46], event.keyCode) # space, backspace, delete
        s._unSplit('') if s.queryOnly && !s.nearby?.length && _.contains([8], event.keyCode)
        s._calcNearbySplit() 

      s._spacedBefore = (phrase) -> if phrase && phrase.length then " " + phrase else ''
        
      s.clearNearby = () -> 
        s.nearby = null
        console.log( "q:#{s.query},qo:#{s.queryOnly},s:#{s.splitTerm},n:#{s.nearby}" )

      s._unSplit = () ->
        s.query = s.queryOnly + s.splitTerm?.replace(' ', '') + s._spacedBefore(s.nearby)
        s.queryOnly = s.splitTerm = s.nearby = null
        console.log($('#primary').css('display'))
        $(".expanded-search-and-filter input#primary").focus()
        return true

      s._calcNearbySplit = ->
        if s.splitTerm
          split = s.query.split(s.splitTerm)
          s._executeSplit(split) if !s.queryOnly # && split[1]?.length > 1
        return true

      s._executeSplit = (split) ->
        s.queryOnly = split[0]
        s.nearby ||= split[1]
        console.log($('#secondary').css('display'))
        $(".expanded-search-and-filter input#secondary").focus()
        return true

      s._checkNearbySplit = ->
        s.typing = true unless s.typing
        splitTerms = [ ' in ', ' near ', ' nearby ', ' around ', ' @ ', ", " ].join('|') if !s.overrideSplit
        splitTerms = ' @@ ' if s.overrideSplit
        splitTerm = s.query.match(new RegExp(splitTerms)) unless !s.query
        if splitTerm?.length
          s.splitTerm = splitTerm[0].replace(' ', '') # first split term used
        return true

      s.overrideSplit = false

      s.forceUnSplit = ->
        s.overrideSplit = true
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
        place = _.find(s.places, (p) -> p.viewId == viewId)
        window.location.href = "/places/#{place.id}"

      s.canCreatePlace = -> (s.queryOnly?.length || s.query?.length) && s.nearby?.length 

      # NEW PLACE

      s.modal = new Modal('addPin')

      s.createPlace = ->
        return unless s.canCreatePlace() && s.userId && !s.currentEvent
        s.hideSearch()
        s.modal.show({ loading: 'longer' })

        Place.complete({ user_id: s.userId, name: (s.queryOnly || s.query), nearby: (s.nearby || s.nearbyOnly) })
          .success (response) ->
            if place = response.place
              s.modal.show({ nearby: s.nearby, query: s.query, mark: response })
            else
              s.modal.show({ nearby: s.nearby, query: s.query })
            s.query = s.nearby = s.queryOnly = s.nearbyOnly = null
          .error ->
            s.modal.show({ error: true })
            ErrorReporter.report({ userId: s.userId, nearby: s.nearby || s.nearbyOnly, query: s.queryOnly || s.query })
            s.query = s.nearby = s.queryOnly = s.nearbyOnly = null

      s.createPlace = ->
        return unless s.canCreatePlace() && s.userId
        s.hideSearch()
        $('#planit-modal-new .initiate').hide()
        $('#planit-modal-new .loading').show()
        $('#planit-modal-new').modal('toggle')
        Place.complete({ user_id: s.userId, name: (s.queryOnly || s.query), nearby: s.nearby })
          .success (response) ->
            s.query = s.nearby = s.queryOnly = s.overrideSplit = null
            if place = response.place
              s._confirmEvent(place)
            else
              s._markEvent(response)
          .error ->
            s._errorEvent()
            ErrorReporter.report({ userId: s.userId, nearby: s.nearby, query: s.queryOnly || s.query })
            s.query = s.nearby = s.queryOnly = s.overrideSplit = null
        return true

      s._confirmEvent = (place) ->
        $('#planit-modal-new .loading').hide()
        $('#planit-modal-new .confirm').show()
        $('#planit-modal-new .confirm .bucket-list-title').html( place.name )
        $('#planit-modal-new .confirm .icon').addClass( place.meta_icon )
        $('#planit-modal-new .confirm .categories').html( place.categories.join(', ') )
        $('#planit-modal-new .confirm .bucket-list-img').css( "background-image", "url(#{place.image_url})" )
        $('#planit-modal-new .confirm .place-link').attr( "href", place.href )
        $('#planit-modal-new .confirm .bucket-list-address').html( place.address )
        $('#planit-modal-new .confirm .bucket-list-locale').html( place.locale )
        return true

      s._markEvent = (mark) ->
        $('#planit-modal-new .loading').hide()
        $('#planit-modal-new .choose').show()
        $('#planit-modal-new .choose .choices').attr( "href", mark.href )
        return true

      s._errorEvent = ->
        $('#planit-modal-new .loading').hide()
        $('#planit-modal-new .error').show()
        return true

  }