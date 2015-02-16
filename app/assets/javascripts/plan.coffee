$ ->

# SASHA, IS THERE ANY WAY TO MAKE THIS MORE EFFICIENT?
# KEY IN PERSISTENT HEADER ON SCROLL-DOWN

#   $(window).scroll ->
#     if ( $(@).scrollTop() > 470 )  
#       $('.persistent-header').addClass("sticky")
#     else
#       $('.persistent-header').removeClass("sticky")

# # KEY OUT CAPTION/SEARCH CONTENT WHEN OVERLAPPED

#   $(window).scroll ->
#     if ( $(@).scrollTop() > 450 )  
#       $('.title-and-caption-content').addClass("off-view")
#     else
#       $('.title-and-caption-content').removeClass("off-view")

#   $(window).scroll ->
#     if ( $(@).scrollTop() > 400 )  
#       $('#tagline').addClass("off-view")
#     else
#       $('#tagline').removeClass("off-view")

# # KEY OUT MONEYSHOT PHOTO LEFT/RIGHT WHEN OVERLAPPED

#   $(window).scroll ->
#     if ( $(@).scrollTop() > 200 )  
#       $('.photo-left-right-control').addClass("off-view")
#     else
#       $('.photo-left-right-control').removeClass("off-view")

# # ON-HOVER AND ON-CLICK EVENTS

#   addAndRemoveOnHover = (selector, carrywith1, carrywith2, carrywith3, carrywith4, carrywith5, className='active') ->
#     $(selector).hover( ->
#       $(@).toggleClass className
#       $("div#{carrywith1}").toggleClass className if carrywith1
#       $("div#{carrywith2}").toggleClass className if carrywith2
#       $("div#{carrywith3}").toggleClass className if carrywith3
#       $("div#{carrywith4}").toggleClass className if carrywith4
#       $("div#{carrywith5}").toggleClass className if carrywith5
#     )
#   addAndRemoveOnHover('.header-title', false, false, false, false)
#   addAndRemoveOnHover('.day-map-icon-tab', '.day-map-icon', false, false, false)
#   addAndRemoveOnHover('.leg-map-icon-tab', '.leg-map-icon', false, false, false)
#   addAndRemoveOnHover('.content-tab', false, false, false, false)
#   addAndRemoveOnHover('.tab-row-wrap', false, false, false, false)
#   addAndRemoveOnHover('.timeline-wrap-build', false, false, false, false)    
#   addAndRemoveOnHover('.menu-link.black', false, false, false, false)    
#   addAndRemoveOnHover('.menu-link.white', false, false, false, false)  
#   addAndRemoveOnHover('.user-icon', false, false, false, false)    
#   addAndRemoveOnHover('.exit-view', false, false, false, false)    
#   addAndRemoveOnHover('.flash-alert', false, false, false, false)    
#   addAndRemoveOnHover('.cluster-expansion', false, false, false, false)    
#   addAndRemoveOnHover('.travel-tag', ".travel-tag-get-more", false, false, false)    

#   toggleElementOnDoubleClick = (selector, carrywith, className='clicked') ->
#     $(selector).dblclick( -> 
#       $("div#{carrywith}").addClass className if carrywith
#       $(@).toggleClass className 
#     )
#   toggleElementOnDoubleClick('.cluster-map-expandible', '.cluster-expansion')
#   toggleElementOnDoubleClick('.cluster-expansion', false)

#   toggleElementOnClick = (selector, carrywith1, carrywith2, carrywith3, carrywith4, carrywith5, className='clicked') ->
#     $(selector).click( -> 
#       $("div#{carrywith1}").toggleClass className if carrywith1
#       $("div#{carrywith2}").toggleClass className if carrywith2
#       $("div#{carrywith3}").toggleClass className if carrywith3
#       $("div#{carrywith4}").toggleClass className if carrywith4
#       $("div#{carrywith5}").toggleClass className if carrywith5
#       $(@).toggleClass className )
#   toggleElementOnClick('.flash-alert', false, false)
#   toggleElementOnClick('#min_max', '.plan-content-row', '.content-tab', '.tab-row-wrap', '.travel-tag-get-more', '.content-tab-title')
#   # toggleElementOnClick('#min_max', '.plan-content-row', '.content-tab', '.travel-tag-get-more')

#   # cycleImageOnClick = (selector, className='clicked') ->

#   #   moneyshotNumber = $john-muir-trail.data.moneyshots.length
#   #   $(selector).click( 
#   #     -> alert(moneyshotNumber)
#   #     # -> $(@).removeClass classNameEdited 
#   #   )
#   # # .moneyshot{ style: "background-image: url('#{image_path @data.moneyshots[0]['url']}')" }

#   # cycleElementOnClick('.moneyshot')



