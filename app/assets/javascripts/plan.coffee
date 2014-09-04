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
  addAndRemoveOnHover('.exit-view')    
  addAndRemoveOnHover('.flash-alert')    
  addAndRemoveOnHover('.cluster-expansion')    

  toggleElementOnDoubleClick = (selector, carrywith, className='clicked') ->
    $(selector).dblclick( -> 
      $("div#{carrywith}").addClass className if carrywith
      $(@).toggleClass className 
    )
  toggleElementOnDoubleClick('.cluster-map-expandible', '.cluster-expansion')
  toggleElementOnDoubleClick('.cluster-expansion', false)

  toggleElementOnClick = (selector, carrywith, carrywith2, className='clicked') ->
    $(selector).click( -> 
      $("div#{carrywith}").toggleClass className if carrywith
      $("div#{carrywith2}").toggleClass className if carrywith2
      $(@).toggleClass className )
  toggleElementOnClick('.flash-alert', false, false)
  toggleElementOnClick('#min_max', '.plan-content-row', '.content-tab')

  # cycleImageOnClick = (selector, className='clicked') ->

  #   moneyshotNumber = $john-muir-trail.data.moneyshots.length
  #   $(selector).click( 
  #     -> alert(moneyshotNumber)
  #     # -> $(@).removeClass classNameEdited 
  #   )
  # # .moneyshot{ style: "background-image: url('#{image_path @data.moneyshots[0]['url']}')" }

  # cycleElementOnClick('.moneyshot')



