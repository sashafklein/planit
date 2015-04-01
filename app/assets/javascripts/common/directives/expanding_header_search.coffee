angular.module("Common").directive 'expandingHeaderSearch', (BarExpander) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "expanding_header_search.html"
    scope:
      showTeaser: '@'

    link: (s, element) ->

      s.searchClick = -> if s.showTeaser == 'true' then true else false

      $('.searching-mask').click -> s.hideSearch()

      s.showSearch = -> BarExpander.expandBar()

      s.hideSearch = -> 
        $('.searching-mask').hide()
        $('#planit-header').removeClass("focused")
        $(".logo-container, .side-menu-container, .top-menu-container, .search-teaser").fadeIn("fast")
        element.find(".expanded-top-search-bar").fadeOut('fast')
        $(".mobile-center-search").show() if $(".mobile-center-search").css('display') == 'none'
        return true

  }