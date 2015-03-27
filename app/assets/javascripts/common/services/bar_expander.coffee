angular.module("Services").factory "BarExpander", () ->

  class BarExpander

    @expandBar: ->
      $(".logo-container, .side-menu-container, .top-menu-container, .search-teaser").fadeOut("fast")
      $('#planit-header').addClass("focused")
      $(".searching-mask, .expanded-search-and-filter").fadeIn("fast")
      if $(".expanded-search-and-filter input#primary").css('display') != 'none'
        $(".expanded-search-and-filter input#primary").focus()
      else if $(".expanded-search-and-filter input#secondary").css('display') != 'none'
        $(".expanded-search-and-filter input#secondary").focus()
      $(".mobile-center-search").css('display', 'none') if $(".mobile-center-search").css('display') != 'none'
      return true

  return BarExpander