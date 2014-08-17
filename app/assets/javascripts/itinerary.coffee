$ ->

  $(window).scroll ->
    if ( $(@).scrollTop() > 1 )  
      $('persistent_header').addClass("sticky")
    else
      $('persistent_header').removeClass("sticky")

  if $('itineraries itineraries-show')
    for mapName in $('#map-list').data('list').split('+')
      map = new Map(mapName)
      window.map = map
      map.paint()