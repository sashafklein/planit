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

      s.showSearch = ->
        $(".logo-container, .side-menu-container, .top-menu-container, .search-teaser").fadeOut("fast")
        $('#planit-header').addClass("focused")
        $('.searching-mask').fadeIn("fast")
        element.find(".expanded-search-and-filter").fadeIn("fast")
        element.find("#search-input-field").focus()
        return true

      s.clearSearch = -> s.query = s.places = s.nearby = s.currentEvent = s.makingRequest = null

      s.showResults = -> !s.typing && (s.query?.length) || (s.places?.length)
      s.hideSearch = -> 
        $('.searching-mask').hide()
        $('#planit-header').removeClass("focused")
        $(".logo-container, .side-menu-container, .top-menu-container, .search-teaser").fadeIn("fast")
        element.find(".expanded-search-and-filter").fadeOut('fast')
        if element.find('#search-input-field').val().length == 0 
          element.find('#search-teaser-field').html('')
        element.find('#search-input-field').val($('#search-teaser-field').html())
        return true

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
          event.preventDefault()
          switch event.keyCode
            when 13 then s._goTo(s.currentPlaceId) # enter
            when 40 then s.togglePosition(1) # down arrow
            when 38 then s.togglePosition(-1) # up arrow
            when 9 then  s._focusOnNearby()
        else
          s.typing = true unless s.typing

      s._turnOffTyping = _.debounce( (=> s.typing = false), 300)
      s.handleKeyup = -> s._turnOffTyping()

      s.togglePosition = (num) ->
        return s.currentPlaceId = 0 unless s.places?.length
        position = (s.currentPlaceId + num) %% s.places.length
        s.currentPlaceId = if position == 0 then s.places.length else position

      s.selectPlace = (place) -> s.currentPlaceId = place.viewId
      s.deselectPlace = -> s.currentPlaceId = 0

      s._searchFunction = _.debounce( s._makeSearchRequest, 300 )
      s.search = -> s._searchFunction()

      s.canCreatePlace = -> s.query?.length && s.nearby?.length
      s.createPlace = ->
        return unless s.canCreatePlace() && s.userId && !s.currentEvent

        s.currentEvent = s._loadingEvent()
        Place.complete({ user_id: s.userId, name: s.query, nearby: s.nearby })
          .success (response) ->
            s.query = s.nearby  = null
            if response.place
              s.currentEvent = null
              s.places = [Place.generateFromJSON(response.place)]
            else
              s.currentEvent = s._markEvent(response)
          .error ->
            s.currentEvent = s._errorEvent()
            ErrorReporter.report({ userId: s.userId, nearby: s.nearby, query: s.query })
            s.query = s.nearby = null
            s.error = true

      s._markEvent = (mark) ->
        href: mark.href
        tabClass: 'place-options-mark'
        iconClass: 'fa-exclamation-triangle'
        text: $sce.trustAsHtml '<p>Well, we found <em>something...</em></p><p>Click to check it out.</p>'

      s._errorEvent = ->
        tabClass: 'error'
        iconClass: 'fa-exclamation-triangle'
        text: $sce.trustAsHtml "<p>We couldn't find a place by that name and location!</p><p>We've been notified.</p>"

      s._loadingEvent = ->
        tabClass: 'loading'
        iconClass: 'fa-spin fa-spinner'
        text: $sce.trustAsHtml "<p>We're scouring the internet.</p><p>This may take a second.</p>"

      s._goTo = (viewId) ->
        place = _.find(s.places, (p) -> p.viewId == viewId)
        window.location.href = "/places/#{place.id}"

      s._focusOnNearby = ->
        element.find('.input-group.new-entry-nearby input').focus()
        true

      $('.searching-mask').click -> s.hideSearch()

      window.s = s

  }