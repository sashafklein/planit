$ ->

# SASHA, IS THERE ANY WAY TO MAKE THIS MORE EFFICIENT?
# KEY IN PERSISTENT HEADER ON SCROLL-DOWN

  $(window).scroll ->
    if ( $(@).scrollTop() > 470 )  
      $('.persistent-header').addClass("sticky")
    else
      $('.persistent-header').removeClass("sticky")

# KEY OUT CAPTION/SEARCH CONTENT WHEN OVERLAPPED

  $(window).scroll ->
    if ( $(@).scrollTop() > 450 )  
      $('.title-and-caption-content').addClass("off-view")
    else
      $('.title-and-caption-content').removeClass("off-view")

# KEY OUT MONEYSHOT PHOTO LEFT/RIGHT WHEN OVERLAPPED

  $(window).scroll ->
    if ( $(@).scrollTop() > 200 )  
      $('.photo-left-right-control').addClass("off-view")
    else
      $('.photo-left-right-control').removeClass("off-view")

  if $('.itineraries.itineraries-show').length
    for mapName in $('#map-list').data('list').split('+')
      map = new Map(mapName)
      map.paint()

  addAndRemoveOnHover = (selector, className='active') ->
    $(selector).hover(
      -> $(@).addClass className,
      -> $(@).removeClass className 
    )

  addAndRemoveOnHover('.header-title')
  addAndRemoveOnHover('.photo-left-right-control.left')
  addAndRemoveOnHover('.photo-left-right-control.right')
  addAndRemoveOnHover('.content-tab')
  addAndRemoveOnHover('.timeline-wrap-build')    

  changeElementOnClick = (selector, className='clicked') ->
    $(selector).click( -> $(@).toggleClass className )

  changeElementOnClick('.cluster-map-expandible')
