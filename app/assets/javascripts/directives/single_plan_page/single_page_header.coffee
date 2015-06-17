angular.module("Directives").directive 'singlePageHeader', () ->
  restrict: 'E'
  replace: true
  templateUrl: 'single/_single_page_header.html'
  scope:
    m: '='
  link: (s, e, a) ->

    s.toggleMainMenu = -> s.m.mainMenuToggled = !s.m.mainMenuToggled
    
    s.bestLocation = -> if s.m.currentLocation()?.clusterName?.length>0 then s.m.currentLocation().clusterName else if s.m.currentLocation()?.name?.length>0 then s.m.currentLocation().name
    # s.yOffset = -> s.yOffsetIs = $(window).scrollTop()
    # s.$watch( 'yOffset()', (-> s.setOpacity() ), true)

    # s.opacityStyle = "{ 'background': '(255,255,255,0)' }"
    # s.setOpacity = -> 
    #   y = parseInt(s.yOffsetIs) if s.yOffsetIs
    #   console.log y
    #   if !y || y < 1
    #     opacity = 0
    #   else if y && y < 100
    #     opacity = parseFloat( y / 100 )
    #   else
    #     opacity = 1
    #   console.log "background: (255,255,255,#{ opacity })"
    #   s.opacityStyle = "{ 'background': '(255,255,255,#{ opacity })' }"
