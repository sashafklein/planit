angular.module("Common").directive 'fullSiteSearchField', (Place) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "full_site_search_field.html"
    scope:
      showFilter: '@'

    link: (s, element) ->

      s.currentPlaceId = 0 

      s.showSearch = ->
        $(".logo-container, .side-menu-container, .top-menu-container, .search-teaser").fadeOut("fast")
        $('#planit-header').addClass("focused")
        $('.searching-mask').fadeIn("fast")
        element.find(".expanded-search-and-filter").fadeIn("fast")
        element.find("#search-input-field").focus()
        return true

      s.clearSearch = -> 
        s.query = s.places = null

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
            console.log "Something went wrong!"
            s.makingRequest = false

      s.handleKeydown = (event) ->
        return true unless _.contains([13, 40, 38], event.keyCode)

        switch event.keyCode
          when 13 then s._goTo(s.currentPlaceId) # enter
          when 40 then s.togglePosition(1) # down arrow
          when 38 then s.togglePosition(-1) # up arrow

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

      $('.searching-mask').click -> s.hideSearch()

      window.s = s

  }