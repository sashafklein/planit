#= require jquery

planit =

  timeoutDiv: ->
    setTimeout( 
      => @hideAll(),
      3000
    )

  setLoadingTimeouts: ->
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
    setTimeout(
      => @hideAll(),
      2000
    )

  showManual: ->
    $('#planit-wrapper').fadeOut('fast')    
    $('#planit-manual').slideDown('fast')

  hideAll: ->
    $('#planit-wrapper').fadeOut('fast')
    $('#planit-manual').fadeOut('fast')

  submitForm: ->
    form = $('#submit-form')
    basePath = form.attr('action')
    url = form.find('#planit-current-url').val()
    $.ajax
      url: "#{basePath}?url=#{url}" 
      type: 'POST'
      success: => 
        @showSuccess()
      failure: => 
        @showError("Something went wrong!")

$ ->
  planit.setLoadingTimeouts()
  planit.submitForm()