((e, a, g, h, f, c, b, d) ->
  if not (f = e.jQuery) or g > f.fn.jquery or h(f)
    c = a.createElement("script")
    c.type = "text/javascript"
    c.src = "http://ajax.googleapis.com/ajax/libs/jquery/" + g + "/jquery.min.js"
    c.onload = c.onreadystatechange = ->
      if not b and (not (d = @readyState) or d is "loaded" or d is "complete")
        h (f = e.jQuery).noConflict(1), b = 1
        f(c).remove()
      return

    document.body.appendChild( c )
  return
) window, document, "1.3.2", ($, L) ->

  path = window.location.href

  div = -> $('#planit-bookmarklet')

  acceptedPath = (pathName) -> true

  timeoutDiv = ->
    setTimeout( 
      -> div().fadeOut('slow'),
      3000
    )

  getPageData = () -> 'SPECIFIC_FILE'

  getDivTemplate = (message, button=false, callback) ->
    post_path = "HOSTNAME/api/v1/bookmarklets/base"
    $.get(post_path, callback)

  showDiv = (message, button=false) ->
    if div().length
      getDivTemplate message, button, (response) ->
        div().replaceWith(response)
        div().fadeIn('slow')
        setTriggers()
    else
      getDivTemplate message, button, (response) ->
        $('body').prepend(response)
        div().fadeIn('slow')
        setTriggers()

    timeoutDiv() unless button

  setTriggers = () ->
    $('#planit-click-save').click (e) ->
      pageData = getPageData()
      alert JSON.stringify(pageData)
      e.preventDefault()
      $.ajax
        url: "HOSTNAME/api/v1/bookmarklets/save_item" 
        type: 'POST'
        dataType: 'json'
        data: pageData
        success: -> 
          $('#saved-message-flash').fadeIn('slow')
        failure: -> 

    $('#planit-click-cancel').click (e) -> 
      e.preventDefault()
      div().fadeOut('slow')


  #### BASE BEHAVIOR
  if acceptedPath(path)
    showDiv "Do you want to submit this item to Planit?", true
  else
    # This isn't happening yet