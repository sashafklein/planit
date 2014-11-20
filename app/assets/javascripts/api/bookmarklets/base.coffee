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

  timeoutDiv = ->
    setTimeout( 
      -> hideAll(),
      3000
    )
  
  parsePage = () ->
    page = document.getElementsByTagName('html')[0].innerHTML
    url = window.location.href
    console.log 'page', page
    console.log 'url', url
    # console.log url, page
    # console.log('sending parse request to url: "HOSTNAME/api/v1/users/USER_ID/marks/scrape" ')
    $.ajax
      url: "HOSTNAME/api/v1/users/USER_ID/marks/scrape?url=#{url}" 
      type: 'POST'
      dataType: 'json'
      data: 
        url: url
        page: page
      success: -> showSuccess()
      failure: -> showError()

  # INJECT BOOKMARKLET

  launchTool = (andThen) ->
    getDivTemplate(andThen) unless $('#planit-bookmarklet').length
  
  getDivTemplate = (callback) ->
    $.ajax
      url: "HOSTNAME/api/v1/bookmarklets/view"
      success: (response) -> callback(response)
  
  insertDiv = (response) ->
    $('body').prepend(response)
    # console.log('prepended')
    setTimeout( 
      -> initiateTool(), 
      100
    )

  # DISPLAY/HIDE FUNCTIONS
  initiateTool = ->
    # showLoading() #show life
    if true
      load(parsePage)
    else
      showManual()

  load = (behavior) ->
    $('#planit-wrapper').fadeIn('fast')
    $('#planit-loading').fadeIn('fast')
    behavior()
    setLoadingTimeouts()

  setLoadingTimeouts = ->
    setLoadMessage("Loading...")
    setTimeout( 
      -> 
        setLoadMessage("Hold tight.")
        setTimeout(
          ->
            setLoadMessage("This can take a while.")
            setTimeout(
              -> 
                setLoadMessage("Complicated page!")
                setTimeout(
                  -> showError("Woops! Taking too long... ;-("),
                  5000
                )
              ,
              5000
            )
          ,
          5000
        )
      ,
      3000
    )
  setLoadMessage = (message) ->
    $('#planit-loading').html(message) unless $('#planit-loading').css('display') == 'none'

  setLoadingTimeout = (message, time) ->
    setTimeout( 
      -> $('#planit-loading').html(message) unless $('$planit-loading').css('display') == 'none',
      time
    )

  showSuccess = -> 
    # console.log 'in success'
    $('#planit-loading').fadeOut('fast')
    $('#planit-manual').fadeOut('fast')
    $('#planit-success').fadeIn('slow')
    # $('#planit-noteWrap').fadeIn('slow')

  showError = (errorMsg) -> 
    # console.log 'in error', errorMsg
    $('#planit-loading').fadeOut('fast')    
    $('#planit-success').fadeOut('fast')    
    # $('#planit-noteWrap').fadeOut('fast')    
    $('#planit-error').fadeIn('slow')
    $('#planit-error').html(errorMsg)    
    setTimeout(
      -> hideAll(),
      5000
    )

  showManual = ->
    $('#planit-wrapper').fadeOut('fast')    
    $('#planit-manual').slideDown('fast')

  hideAll = ->
    $('#planit-wrapper').fadeOut('fast')
    $('#planit-manual').fadeOut('fast')

  # INITIAL BEHAVIOR
  launchTool(insertDiv)