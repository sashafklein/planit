angular.module("Common").directive 'fullSiteSearchField', () ->

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

      $('.searching-mask').click -> 
        s.hideSearch()
        return true

      s.showSearch = ->
        $(".logo-container, .side-menu-container, .top-menu-container, .search-teaser").fadeOut("fast")
        $('#planit-header').addClass("focused")
        $(".searching-mask, .expanded-search-and-filter").fadeIn("fast")
        $(".expanded-search-and-filter input#primary").focus()
        return true

      s.hideSearch = -> 
        $('.searching-mask').hide()
        $('#planit-header').removeClass("focused")
        $(".logo-container, .side-menu-container, .top-menu-container, .search-teaser").fadeIn("fast")
        element.find(".expanded-search-and-filter").fadeOut('fast')
        if element.find('#search-input-field').val().length == 0 
          element.find('#search-teaser-field').html('')
        element.find('#search-input-field').val($('#search-teaser-field').html())
        return true