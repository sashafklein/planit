angular.module("Common").directive 'fullSiteSearchField', (Place) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "full_site_search_field.html"
    scope:
      showFilter: '@'

    link: (s, element) ->

      s.showSearch = ->
        element.find(".logo-container, .side-menu-container, .top-menu-container, .search-and-filter-wrap").fadeOut("fast")
        element.find(".expanded-search-and-filter").fadeIn("fast")
        element.find('#planit-header').addClass("focused")
        element.find("#search-input-field").focus()
        return true

      s.clearSearch = -> s.query = null

      s.hideSearch = -> 
        element.find('#planit-header').removeClass("focused")
        element.find(".expanded-search-and-filter").fadeOut('fast')
        element.find(".logo-container, .side-menu-container, .top-menu-container, .search-and-filter-wrap").fadeIn("fast")
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
            s.makingRequest = false
          .error (response) ->
            console.log "Something went wrong!"
            s.makingRequest = false

      s._searchFunction = _.debounce( s._makeSearchRequest, 300 )
      s.search = -> s._searchFunction()

      window.s = s

  }