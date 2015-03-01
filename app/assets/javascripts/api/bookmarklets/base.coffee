planit =

  timeoutDiv: ->
    setTimeout( 
      => @hideAll(),
      3000
    )

  setLoadingTimeouts: ->
    $('#planit-bookmarklet').show()
    $('#planit-wrapper').show()
    $('#planit-loading').show()
    setTimeout( 
      => 
        @setLoadMessage("Hold tight.")
        setTimeout(
          =>
            @setLoadMessage("This can take a while.")
            setTimeout(
              => 
                @setLoadMessage("Complicated page!")
                setTimeout(
                  => @showError("Woops! Taking too long... ;-("),
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

  setLoadMessage: (message) ->
    $('#planit-loading').html(message) unless $('#planit-loading').css('display') == 'none'

  setLoadingTimeout: (message, time) ->
    setTimeout( 
      -> $('#planit-loading').html(message) unless $('$planit-loading').css('display') == 'none',
      time
    )

  showSuccess: -> 
    $('#planit-loading').fadeOut('fast')
    $('#planit-loading').html('')
    $('#planit-manual').fadeOut('fast')
    $('#planit-success').fadeIn('slow')
    setTimeout(
      => @hideAll(),
      2000
    )

  showError: (errorMsg) -> 
    $('#planit-loading').fadeOut('fast')    
    $('#planit-success').fadeOut('fast')    
    $('#planit-error').fadeIn('slow')
    $('#planit-error').html(errorMsg)    
    setTimeoutadsf(
      => @hideAll(),
      2000
    )

  showManual: ->
    $('#planit-wrapper').fadeOut('fast')    
    $('#planit-manual').slideDown('fast')

  hideAll: ->
    $('#planit-wrapper').fadeOut('fast')
    $('#planit-manual').fadeOut('fast')


do ->

  unless window.jQuery
    script = document.createElement("SCRIPT")
    script.src = 'https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js'
    script.type = 'text/javascript'
    document.getElementsByTagName("head")[0].appendChild(script)

  checkReady = (callback) ->
    if (window.jQuery)
      callback(jQuery)
    else
      window.setTimeout( (-> checkReady(callback)), 20)

  checkReady ($) ->
    $ ->

      html = document.documentElement.innerHTML

      loaded = 0
      iframe = document.createElement('iframe')

      iframe.name = 'planit-bookmarklet-' + Math.floor(Math.random() * 10000 + 1)
      iframe.style.display = 'none'

      iframe.onload = ->
        return if ++loaded == 1

        document.body.removeChild iframe
        $.get("HOSTNAME/api/v1/bookmarklets/view?user_id=USER_ID&url=#{ window.location.href }")
          .success (response) ->
            body = document.getElementsByTagName('body')[0]
            div = document.createElement('div')
            div.innerHTML = response
            div.id = 'planit-bookmarklet'
            div.style.display = 'none'
            body.insertBefore(div, body.firstChild)

            planit.setLoadingTimeouts()
          .error (response) ->
            console.log response  

      form = document.createElement('form')
      form.method = 'POST'
      form.action = "HOSTNAME/api/v1/users/USER_ID/marks/scrape?url=#{ window.location.href }&nocache=#{ Math.random() }"
      form.target = iframe.name

      textarea = document.createElement('textarea')
      textarea.name = 'page'
      textarea.value = html
      
      form.appendChild textarea
      iframe.appendChild form
      document.body.appendChild iframe

      form.submit()
