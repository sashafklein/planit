angular.module('Common').factory 'SearchBar', (QueryString) ->

  class SearchBar

    @_removeBlanks: (string) ->
      string.replace(/\s\s+/g, ' ').replace(/^\s*/g, '').replace(/\s*$/g, '') unless !string

    @_searchToggleOn: () -> 
      $(".logo-container, .side-menu-container, .top-menu-container, .search-and-filter-wrap").fadeOut("fast")
      $(".expanded-search-and-filter").fadeIn("fast")
      $('#planit-header').addClass("focused")
      $("#search-input-field").focus()

    @_searchToggleOff: () -> 
      $('#planit-header').removeClass("focused")
      $(".expanded-search-and-filter").fadeOut('fast')
      $(".logo-container, .side-menu-container, .top-menu-container, .search-and-filter-wrap").fadeIn("fast")
      if $('#search-input-field').val().length == 0 
        QueryString.clearParamValues(q:'clear')
        $('#search-teaser-field').html('')
      $('#search-input-field').val($('#search-teaser-field').html())

    @_searchToggleText: (stay_open=null) ->
      searchVal = SearchBar._removeBlanks( $('#search-input-field').val() )
      QueryString.modifyParamValues(q:searchVal)
      $('#search-teaser-field').html(searchVal)
      @_searchToggleOff() unless ( searchVal.length == 0 || stay_open )

    # INITIALIZE

    @initializePage: () ->
      if typeof $('#search-input-field').val() == 'string'
        $('#search-input-field').val(QueryString.fetchQuery())
        $('#search-teaser-field').html(QueryString.fetchQuery())
        $('.search-teaser').click -> SearchBar._searchToggleOn()
        $(".search-close, html").click -> SearchBar._searchToggleOff()
        $('.expanded-search-and-filter, .search-teaser, .filter-dropdown-menu').click (event) -> event.stopPropagation()
        $('#search-input-button').click -> SearchBar._searchToggleText()
        $('#search-input-field').keyup -> 
          if event.keyCode == 13 then SearchBar._searchToggleText()
          if event.keyCode == 32 then SearchBar._searchToggleText(true)

  return SearchBar
