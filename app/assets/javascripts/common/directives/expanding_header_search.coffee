angular.module("Common").directive 'expandingHeaderSearch', (BarExpander) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "expanding_header_search.html"
    scope:
      showFilter: '@'
      showTeaser: '@'

    link: (s, element) ->

      s.fullWidth = -> if s.showFilter == 'false' then true else false
      s.searchClick = -> if s.showTeaser == 'true' then true else false

      $('.searching-mask').click -> s.hideSearch()

      s.showSearch = -> BarExpander.expandBar()

      s.hideSearch = -> 
        $('.searching-mask').hide()
        $('#planit-header').removeClass("focused")
        $(".logo-container, .side-menu-container, .top-menu-container, .search-teaser").fadeIn("fast")
        element.find(".expanded-search-and-filter").fadeOut('fast')
        $(".mobile-center-search").show() if $(".mobile-center-search").css('display') == 'none'
        return true

  }