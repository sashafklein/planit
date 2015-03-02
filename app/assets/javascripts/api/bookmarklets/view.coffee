#= require jquery

planit =

  setLoadingTimeouts: ->
    $('#planit-bookmarklet-bar').slideDown(200)
    $('#planit-close-button, #planit-x-button').click -> planit.hideAll()
    setTimeout( 
      => 
        $('#planit-loading').fadeIn(200)
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
                  4000
                )
              ,
              3000
            )
          ,
          2000
        )
      ,
      200
    )

  setLoadMessage: (message) ->
    $('#planit-loading').html(message) unless $('#planit-loading').css('display') == 'none'

  hideAll: ->
    $('.planit-message').hide(0)
    $('#planit-bookmarklet-bar').slideUp('fast')

  disappearingAct: (time=0) ->
    planit.disappearTimer = setTimeout(
      -> planit.hideAll(),
      time
  )

  mouseEvents: () ->
    $('#planit-bookmarklet-bar').on 'mouseover', -> clearTimeout( planit.disappearTimer )
    $('#planit-bookmarklet-bar').on 'mouseleave', -> 
      if $('#planit-loading').css('display') == 'none'
        planit.disappearingAct(2000)

  showSuccess: ->
    $('#planit-loading').html('')
    $('#planit-loading, #planit-error, .planit-working-actions').hide(0)
    $('.planit-success-actions, #planit-success, #tags').fadeIn(200)
    @disappearingAct(3000)
    @mouseEvents() 

  showError: (errorMsg) -> 
    $('#planit-error').html(errorMsg)    
    $('#planit-loading, #planit-success').hide(0)    
    $('#planit-error').show(0)
    @disappearingAct(2000)
    @mouseEvents() 

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
  planit.mouseEvents()
