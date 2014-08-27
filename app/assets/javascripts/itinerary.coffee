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

  $(window).scroll ->
    if ( $(@).scrollTop() > 400 )  
      $('#tagline').addClass("off-view")
    else
      $('#tagline').removeClass("off-view")

# KEY OUT MONEYSHOT PHOTO LEFT/RIGHT WHEN OVERLAPPED

  $(window).scroll ->
    if ( $(@).scrollTop() > 200 )  
      $('.photo-left-right-control').addClass("off-view")
    else
      $('.photo-left-right-control').removeClass("off-view")

# ON-HOVER AND ON-CLICK EVENTS

  addAndRemoveOnHover = (selector, className='active') ->
    $(selector).hover(
      -> $(@).addClass className,
      -> $(@).removeClass className 
    )
  addAndRemoveOnHover('.header-title')
  addAndRemoveOnHover('.content-tab')
  addAndRemoveOnHover('.content-tab-title')
  addAndRemoveOnHover('.timeline-wrap-build')    
  addAndRemoveOnHover('.menu-link.black')    
  addAndRemoveOnHover('.menu-link.white')  
  addAndRemoveOnHover('.user-icon')    

  toggleElementOnClick = (selector, className='clicked') ->
    $(selector).click( -> $(@).toggleClass className )
  toggleElementOnClick('.cluster-map-expandible')

  # cycleImageOnClick = (selector, className='clicked') ->

  #   moneyshotNumber = $john-muir-trail.data.moneyshots.length
  #   $(selector).click( 
  #     -> alert(moneyshotNumber)
  #     # -> $(@).removeClass classNameEdited 
  #   )
  # # .moneyshot{ style: "background-image: url('#{image_path @data.moneyshots[0]['url']}')" }

  # cycleElementOnClick('.moneyshot')

  # if $('.itineraries.itineraries-show').length
  #   for mapName in $('#map-list').data('list').split('+')
  #     map = new Map(mapName)
  #     map.paint()

  lat = 37.2371625
  lon = -118.8798368
  zoom = 8
  mb_id = "nikoklein.j9bb9gab"
  mb_access_token = "pk.eyJ1Ijoibmlrb2tsZWluIiwiYSI6IkprTE5iNkEifQ.IcUYpiiJ4NClaj1eAas4Mw"
  
  example_tiles = "http://api.tiles.mapbox.com/v4/examples.map-zr0njcqy/0/0/0.png?access_token=pk.eyJ1Ijoibmlrb2tsZWluIiwiYSI6IkprTE5iNkEifQ.IcUYpiiJ4NClaj1eAas4Mw"
  mb_tiles = "http://api.tiles.mapbox.com/v4/#{mb_id}/{z}/{x}/{y}.png?access_token=#{mb_access_token}"
  map = L.map('map-overview', scrollWheelZoom:false ).setView([lat, lon], zoom)

  L.tileLayer(mb_tiles, {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
    maxZoom: 18
  }).addTo(map)



