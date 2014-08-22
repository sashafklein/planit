$ ->

  $(window).scroll ->
    if ( $(@).scrollTop() > 470 )  
      $('.persistent-header').addClass("sticky")
    else
      $('.persistent-header').removeClass("sticky")

  if $('.itineraries.itineraries-show').length
    for mapName in $('#map-list').data('list').split('+')
      map = new Map(mapName)
      map.paint()

  addAndRemoveOnHover = (selector, className='active') ->
    $(selector).hover(
      -> $(@).addClass className,
      -> $(@).removeClass className 
    )

  addAndRemoveOnHover('.content-tab')
  addAndRemoveOnHover('.timeline-wrap-build')    