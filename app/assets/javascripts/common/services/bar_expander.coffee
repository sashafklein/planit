angular.module("Services").factory "BarExpander", () ->

  class BarExpander

    @expandBar: ->
      $(".logo-container, .side-menu-container, .top-menu-container, .search-teaser").fadeOut("fast")
      $('#planit-header').addClass("focused")
      $(".searching-mask, .expanded-top-search-bar").fadeIn("fast")
      $(".planbox-wrapper").hide() if $(".planbox-wrapper")
      if $(".expanded-top-search-bar input#primary").css('display') != 'none'
        $(".expanded-top-search-bar input#primary").focus()
      else if $(".expanded-top-search-bar input#secondary").css('display') != 'none'
        $(".expanded-top-search-bar input#secondary").focus()
      $(".mobile-center-search").css('display', 'none') if $(".mobile-center-search").css('display') != 'none'
      return true

  return BarExpander