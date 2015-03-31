window.planit = planit =

  # pollForSuccess: (shouldSubmitData, secondsLeft) ->
  #   return @showError() unless secondsLeft >= 0

  #   $.ajax
  #     crossDomain: true
  #     dataType: 'json'
  #     url: planit._testPath()
  #     success: (response) ->
  #       if response && response.mark_id
  #         planit.showSuccess( response.mark_id, response.place_id )
  #       else # Hasn't saved
  #         planit._submitData() if shouldSubmitData
  #         setTimeout( (-> planit.pollForSuccess( false, secondsLeft - 1 )), 1000 )
  #     error: (response) ->
  #       planit.showError()

  injectView: ->
    $('.header-wrapper').css('z-index', 100) if $('.header-wrapper')
    head = document.getElementsByTagName('head')[0]
    stylesheet = document.createElement('style')
    stylesheet.type = 'text/css'
    stylesheet.innerHTML = @_styles
    head.appendChild(stylesheet)

    body = document.getElementsByTagName('body')[0]
    view = document.createElement("div")
    view.id = 'planit-bookmarklet'
    view.innerHTML = @_viewFile
    body.insertBefore(view, body.firstChild)

  setLoadingTimeouts: ->
    $('#planit-bookmarklet').show()
    # $('#planit-close-button, #planit-x-button').click -> planit.hideAll()
    # $('#planit-message').fadeIn(400)
    # setTimeout(
    #   => @cycleMessages(@messageCarousel), 
    #   3500
    # )

  showSuccess: (markId, placeId) -> 
    $('#planit-x-button').click -> planit.hideAll(); planit.hideAll()
    $('.planit-working-actions').hide(0)
    @setPlanitMessage( 'Page bookmarked.' )
    $('#planit-bookmarklet-bar').slideDown(200)
    # $('#planit-success-link').attr( 'href', @_markPath(markId) )
    # $('.planit-success-actions').fadeIn('slow')
    # @disappearingAct(4000)
    # @mouseEvents() 
    planit.disappearingAct(4000)

  showError: (errorMsg) ->
    $('#planit-x-button').click -> planit.hideAll(); planit.hideAll() 
    if errorMsg
      @setErrorMessage(errorMsg)
    else
      @setErrorMessage("Oops! Something went wrong.")
      $.ajax
        crossDomain: true
        dataType: 'json'
        url: planit._errorPath()
        success: (response) ->
          setTimeout( (=> @setErrorMessage("We've been notified")), 1000 )
        error: (response) ->
          setTimeout( (=> @setErrorMessage("Auto-reporting also failed! Please <a href='mailto:hello@plan.it?subject=Bookmarklet%20Failure&content=Page:%20#{window.location.href}'>let us know!</a>")), 1000 )

  setErrorMessage: (message) ->
    @setPlanitMessage( message )
    @disappearingAct(4000)
    @mouseEvents()

  disappearingAct: (time=0) ->
    planit.disappearTimer = setTimeout(
      -> planit.hideAll(),
      time
    )

  mouseEvents: () ->
    $('#planit-bookmarklet-bar').mouseover -> clearTimeout( planit.disappearTimer )
    $('#planit-bookmarklet-bar').mouseleave -> 
      if $('.planit-working-actions').css('display') == 'none'
        planit.disappearingAct(2000)
    $('#planit-x-button').click -> planit.hideHall()

  # messageCarousel: [
  #   "Hold tight.",
  #   "This can take a while.",
  #   "Uh, everything's under control...",
  #   "Wow, complicated page!",
  #   "As Justin Bieber said...",
  #   "The force is strong with this one!",
  #   "Almost there...",
  #   "It's a trap!?",
  # ]

  hideAll: -> 
    $('#planit-bookmarklet-bar').slideUp(450)
    setTimeout(
      -> $('#planit-bookmarklet').remove(),
      500
    )

  setPlanitMessage: (message) ->
    unless $('#planit-message').css('display') == 'none'
      $('#planit-message').fadeOut(200)
      setTimeout((=> $('#planit-message').html(message); $('#planit-message').fadeIn('fast') ), 250 )

  # cycleMessages: (messages) ->
  #   unless $('.planit-working-actions').css('display') == 'none'
  #     @setPlanitMessage(messages.shift())
  #     if messages.length
  #       setTimeout((=> @cycleMessages(messages)), 3500 )

  _currentUrl: -> encodeURIComponent(window.location.href)
  _markPath: (markId) -> "HOSTNAME/marks/#{markId}"

  _testPath: -> "HOSTNAME/api/v1/bookmarklets/test?user_id=USER_ID&url=#{ planit._currentUrl() }"

  _errorPath: -> "HOSTNAME/api/v1/bookmarklets/report_error?user_id=USER_ID&url=#{ planit._currentUrl() }"

  _miniScrapePath: (data) -> "HOSTNAME/api/v1/users/USER_ID/marks/mini_scrape?url=#{ planit._currentUrl() }&scraped=#{ encodeURIComponent JSON.stringify(data) }&nocache=#{ Math.random() }"
  
  _useIframeSubmit: -> window.location.href.indexOf('yelp.com') == -1

  _submitViaIFrame: ->
    html = document.documentElement.innerHTML

    loaded = 0

    iframe = document.createElement('iframe')
    iframe.name = 'planit-bookmarklet-' + Math.floor(Math.random() * 10000 + 1)
    iframe.style.display = 'none'
    iframe.onload = ->
      return if ++loaded == 1
      document.body.removeChild iframe

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
    planit.showSuccess()

  _submitViaGetRequest: ->
    data = @_getMiniData()

    if data.name || data.names
      $.ajax
        crossDomain: true
        dataType: 'json'
        url: planit._miniScrapePath(data)
        success: (response) ->
          planit.showSuccess()
        error: (response) ->
          planit.showError()
    else
      planit.showError()

  _getMiniData: ->
    data = {}
    if location.host == 'www.yelp.com' && location.href.indexOf('/biz/') != -1
      data.name = $("meta[property='og:title']").attr('content')
      mapData = JSON.parse( $('.lightbox-map').attr('data-map-state') )
      if mapData
        data.lat = mapData.center?.latitude
        data.lon = mapData.center?.longitude
    return data

  submitData: ->
    if @_useIframeSubmit()
      @_submitViaIFrame()
    else
      @_submitViaGetRequest()

  _styles: '''
    body, html {
      margin: 0px;
      padding: 0px;
    }
    body #planit-bookmarklet-bar, html #planit-bookmarklet-bar {
      position: fixed;
      z-index: 2147483646;
      top: 0px;
      padding: 0;
      margin: 0;
      width: 100%;
      text-align: center;
      display: none;
      height: 83px;
      opacity: 1;
      visibility: visible;
      background: #fafafa;
      border-top: 3px solid #1c3093;
      -webkit-box-shadow: rgba(0, 0, 0, 0.2) 0px 1px 0px 0px, rgba(0, 0, 0, 0.15) 0px 2px 7px 0px;
      box-shadow: rgba(0, 0, 0, 0.2) 0px 1px 0px 0px, rgba(0, 0, 0, 0.15) 0px 2px 7px 0px;
    }
    body #planit-bookmarklet-bar .planit-success-actions, html #planit-bookmarklet-bar .planit-success-actions {
      display: none;
      text-align: right;
    }
    body #planit-bookmarklet-bar .planit-working-actions, html #planit-bookmarklet-bar .planit-working-actions {
      display: block;
      text-align: right;
    }
    body #planit-bookmarklet-bar #planit-x-button, html #planit-bookmarklet-bar #planit-x-button {
      transition: 0.2s ease all;
      font-size: 15px;
      font-weight: bold;
      color: #777;
      position: absolute;
      right: 5px;
      top: 5px;
      padding: 5px;
      cursor: pointer;
    }
    body #planit-bookmarklet-bar #planit-x-button:hover, html #planit-bookmarklet-bar #planit-x-button:hover {
      color: #000;
    }
    body #planit-bookmarklet-bar a, body #planit-bookmarklet-bar a:hover, body #planit-bookmarklet-bar a:active, body #planit-bookmarklet-bar a:visited, html #planit-bookmarklet-bar a, html #planit-bookmarklet-bar a:hover, html #planit-bookmarklet-bar a:active, html #planit-bookmarklet-bar a:visited {
      text-decoration: none;
    }
    body #planit-bookmarklet-bar .extras-container, html #planit-bookmarklet-bar .extras-container {
      float: right;
      visibility: visible;
      display: inline-block;
      cursor: pointer;
      margin: 23px 0 0 0;
      z-index: 2;
    }
    body #planit-bookmarklet-bar .extras-container input.planit-tag-field, html #planit-bookmarklet-bar .extras-container input.planit-tag-field {
      display: inline-block;
      border: 1px solid #ccc;
      padding: 0 10px;
      font-family: arial, "trebuchet ms", avenir, arial;
      font-size: 14px;
      line-height: 14px;
      height: 33px;
      -webkit-border-radius: 4px;
      -moz-border-radius: 4px;
      -o-border-radius: 4px;
      border-radius: 4px;
      max-width: 100px;
    }
    body #planit-bookmarklet-bar .extras-container #tags, html #planit-bookmarklet-bar .extras-container #tags {
      display: none;
    }
    body #planit-bookmarklet-bar .logo-container, html #planit-bookmarklet-bar .logo-container {
      float: left;
      visibility: visible;
      display: inline-block;
      cursor: pointer;
      z-index: 2;
    }
    body #planit-bookmarklet-bar .logo-container img, html #planit-bookmarklet-bar .logo-container img {
      float: left;
      margin: 15px 10px 0 0;
    }
    body #planit-bookmarklet-bar .logo-container .logo-image-top, html #planit-bookmarklet-bar .logo-container .logo-image-top {
      width: 42px;
      height: 50px;
    }
    body #planit-bookmarklet-bar .logo-container .logo-name-top, html #planit-bookmarklet-bar .logo-container .logo-name-top {
      width: 86px;
      height: 50px;
    }
    body #planit-close-btn, html #planit-close-btn {
      width: 15px;
      height: 15px;
      background: #ccc;
      position: absolute;
      top: 8px;
      right: 3px;
      border: #ddd solid 1px;
      border-bottom: #999 solid 1px;
      font-size: 10px;
      line-height: 13px;
      text-align: center;
      cursor: pointer;
    }
    body #planit-message, html #planit-message {
      display: inline-block;
      max-width: 300px;
      left: 0;
      right: 0;
      position: absolute;
      margin: 30px auto 0 auto;
      padding: 0;
      font-family: open sans, "trebuchet ms", avenir, arial;
      font-size: 18px;
      line-height: 18px;
      font-weight: bold;
      color: #333;
      z-index: 0;
    }
    body a .planit-button, body a:hover .planit-button, body a:visited .planit-button, body a:active .planit-button, html a .planit-button, html a:hover .planit-button, html a:visited .planit-button, html a:active .planit-button {
      color: #fff;
      border-bottom: 0;
      text-decoration: none !important;
      text-shadow: #760400 0px -1px 0px;
      cursor: pointer;
    }
    body .planit-button, html .planit-button {
      display: inline-block;
      transition: 0.2s all ease;
      padding: 8px 10px 10px 10px;
      border-bottom: 1px solid #700;
      -webkit-border-radius: 4px;
      -moz-border-radius: 4px;
      -o-border-radius: 4px;
      border-radius: 4px;
      font-family: arial, "trebuchet ms", avenir, arial;
      font-size: 14px;
      line-height: 14px;
      font-weight: bold;
      box-sizing: border-box;
      ms-box-sizing: border-box;
      webkit-box-sizing: border-box;
      moz-box-sizing: border-box;
    }
    body .planit-button.neon, html .planit-button.neon {
      color: #fff;
      text-shadow: 1px 1px 1px #b28;
      background: #f06;
      border: 1px solid #c03;
      box-shadow: #e4284e 0px -3px 0px 0px inset, rgba(0, 0, 0, 0.04) 0px 2px 0px 0px;
    }
    body .planit-button.neon:hover, html .planit-button.neon:hover {
      text-shadow: 1px 1px 1px #c39;
      background: #ee3258;
      box-shadow: #da1e44 0px -3px 0px 0px inset, rgba(0, 0, 0, 0.04) 0px 2px 0px 0px;
    }
    body .planit-button.gray, html .planit-button.gray {
      color: #444;
      text-shadow: 1px 1px 1px #ccc;
      background: #ccc;
      border: 1px solid #afafaf;
      box-shadow: #c3c3c3 0px -3px 0px 0px inset, rgba(0, 0, 0, 0.04) 0px 2px 0px 0px;
    }
    body .planit-button.gray:hover, html .planit-button.gray:hover {
      color: #333;
      background: #bbb;
      box-shadow: #b3b3b3 0px -3px 0px 0px inset, rgba(0, 0, 0, 0.04) 0px 2px 0px 0px;
    }

    .large-screen {
      visibility: visible;
      display: block;
    }

    .mobile {
      visibility: hidden;
      display: none !important;
    }

    .bookmarklet-container {
      width: 960px;
      margin: 0 auto;
    }

    @media only screen and (min-width: 768px) and (max-width: 959px) {
      .large-screen {
        visibility: visible;
        display: block;
      }

      .mobile {
        visibility: hidden;
        display: none !important;
      }

      .bookmarklet-container {
        width: 768px;
        margin: 0 auto;
      }
    }
    @media only screen and (max-width: 767px) {
      .large-screen {
        visibility: hidden;
        display: none;
      }

      .mobile {
        visibility: visible;
        display: block !important;
      }

      .bookmarklet-container {
        width: 90%;
        margin: 0 auto;
      }
    }
    @media only screen and (min-width: 480px) and (max-width: 767px) {
      .large-screen {
        visibility: hidden;
        display: none;
      }

      .mobile {
        visibility: visible;
        display: block !important;
      }

      .bookmarklet-container {
        width: 90%;
        margin: 0 auto;
      }
    }

  '''

  _viewFile: '''
    <div id="planit-bookmarklet-bar">
      <div id="planit-x-button">
        &times;
      </div>
      <div class="bookmarklet-container">
        <div class="logo-container">
          <img src="ASSET_PATH/logo_only_black.png" alt='' class="logo-image-top" >
          <img src="ASSET_PATH/logo_name_only_black.png" alt='PLANIT' class="logo-name-top large-screen" >
        </div>
        <div id="planit-message"></div>
        <div class="extras-container">
          <div class="planit-success-actions">
            <a id='planit-success-link' target="_blank">
              <div class="planit-button neon large-screen" id="see-places">
                View Saved Places
              </div>
              <div class="planit-button neon mobile" id="see-places">
                View
              </div>
            </a>
          </div>
           <!-- <div class="planit-working-actions"> -->
             <!-- <div class="planit-button gray" id="planit-close-button"> -->
               <!-- Close -->
             <!-- </div> -->
           <!-- </div> -->
        </div>
      </div>
    </div>
  '''

do ->

  $ = window.$ = $ || window.jQuery
  unless $
    script = document.createElement("SCRIPT")
    script.src = 'https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js'
    script.type = 'text/javascript'
    document.getElementsByTagName("head")[0].appendChild(script)

  setTimeout((->

    checkReady = (callback) ->
      if $
        callback($)
      else
        window.setTimeout( (-> checkReady(callback)), 20)

    checkReady ($) ->
      $ ->
        unless $('#planit-bookmarklet')[0]
          planit.injectView()
          planit.setLoadingTimeouts()
          planit.submitData()

  ))
