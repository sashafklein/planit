angular.module("Common").directive 'fullSiteSearchField', (Place, $timeout, ErrorReporter, $sce, CurrentUser) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "full_site_search_field.html"
    scope:
      showFilter: '@'

    link: (s, element) ->

      s.currentPlaceId = 0 
      s.typing = false
      s.userId = CurrentUser.id

      # BAR VISUALS

      s.fullWidth = -> return true if s.showFilter == 'false'

      $('.searching-mask').click -> s.hideSearch()

      s.showSearch = ->
        $(".logo-container, .side-menu-container, .top-menu-container, .search-teaser").fadeOut("fast")
        $('#planit-header').addClass("focused")
        $('.searching-mask').fadeIn("fast")
        element.find(".expanded-search-and-filter").fadeIn("fast")
        element.find("#search-input-field").focus()
        return true

      s.clearSearch = -> s.query = s.places = s.nearby = s.currentEvent = s.makingRequest = null

      s.showResults = -> !s.typing && ( s.query?.length || s.places?.length )

      s.hideSearch = -> 
        $('.searching-mask').hide()
        $('#planit-header').removeClass("focused")
        $(".logo-container, .side-menu-container, .top-menu-container, .search-teaser").fadeIn("fast")
        element.find(".expanded-search-and-filter").fadeOut('fast')
        if element.find('#search-input-field').val().length == 0 
          element.find('#search-teaser-field').html('')
        element.find('#search-input-field').val($('#search-teaser-field').html())
        return true

      # SEARCH GUTS

      s._makeSearchRequest = ->
        return if s.makingRequest
        s.makingRequest = true
        Place.search(s.query)
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
        return true

      s._checkNearbySplit = ->
        s.typing = true unless s.typing
        splitTerms = [ ' in ', ' near ', ' nearby ', ' around ', ', ' ].join('|')
        splitTerm = s.query.match(new RegExp(splitTerms))
        if splitTerm?.length
          s.splitTerm = splitTerm[0]
        else
          s.splitTerm = s.nearbyOnly = s.queryOnly = null
        return true

      s._turnOffTyping = _.debounce( (=> s.typing = false), 300)
      s.handleKeyup = -> 
        s._turnOffTyping()
        s._checkNearbySplit() if _.contains([32, 8, 46], event.keyCode) # space, backspace, delete
        if s.splitTerm
          s.nearbyOnly = s.query.split(s.splitTerm)[1]
          s.queryOnly = s.query.split(s.splitTerm)[0]
        else
          s.queryOnly = s.nearbyOnly = null
        return true

      s.togglePosition = (num) ->
        return s.currentPlaceId = 0 unless s.places?.length
        position = (s.currentPlaceId + num) %% s.places.length
        s.currentPlaceId = if position == 0 then s.places.length else position

      s.selectPlace = (place) -> s.currentPlaceId = place.viewId
      s.deselectPlace = -> s.currentPlaceId = 0

      s._searchFunction = _.debounce( s._makeSearchRequest, 300 )
      s.search = -> s._searchFunction()

      s._goTo = (viewId) ->
        place = _.find(s.places, (p) -> p.viewId == viewId)
        window.location.href = "/places/#{place.id}"

      s._focusOnNearby = ->
        if !s.nearbyOnly
          element.find('.entry-form input').focus()
        return true

      s.canCreatePlace = -> (s.queryOnly?.length || s.query?.length) && ( s.nearby?.length || s.nearbyOnly?.length )

      # NEW PLACE

      s.createPlace = ->
        return unless s.canCreatePlace() && s.userId && !s.currentEvent
        s.hideSearch()
        $('#planit-modal-new .initiate').hide()
        $('#planit-modal-new .loading').show()
        $('#planit-modal-new').modal('toggle')
        Place.complete({ user_id: s.userId, name: (s.queryOnly || s.query), nearby: (s.nearby || s.nearbyOnly) })
          .success (response) ->
            s.query = s.nearby = s.queryOnly = s.nearbyOnly = null
            if place = response.place
              s._confirmEvent(place)
            else
              s._markEvent(response)
          .error ->
            s._errorEvent()
            ErrorReporter.report({ userId: s.userId, nearby: s.nearby || s.nearbyOnly, query: s.queryOnly || s.query })
            s.query = s.nearby = s.queryOnly = s.nearbyOnly = null
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