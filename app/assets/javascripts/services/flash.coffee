## In an angular file, just include the module and call like so:
##
##    # This will create a regular top-of-page flash
##    Flash.success("You've been successful!")
##
##    # This will create a flash in a specified class/id
##    Flash.error("You failed!", "#specific-flash-id")

angular.module("Services").factory 'Flash',  ($timeout) ->
  alert_selector = '.flash-alert'

  _flashContainer = (location) ->
    if location && location.length > 0
      flash_container = $(location)
    # default flash to top of page
    else 
      flash_container = $('#flash')

  _clearOld = ($flashContainer) ->
    # remove previous flashes in container
    if $(alert_selector).length > 0
      $flashContainer.find(alert_selector).remove() 

  clear: (location = null) ->
     _clearOld(_flashContainer(location))

  error: (content, opts={}) ->
    @new('error', content, location)

  success: (content, opts={}) ->
    @new('success', content, location)

  notice: (content, opts={}) ->
    @new('notice', content, location)

  warning: (content, opts={}) ->
    @new('warning', content, location)  

  new: (type, content, opts={}) ->
    $ ->
      $flashContainer = _flashContainer(opts.location)
      _clearOld($flashContainer)
     
      $flashContainer.append "<div id='flash'><div class='flash-alert' id='flash_#{type}'>#{content}</div></div>"
      $("#flash").fadeIn(500)
      $('html,body').animate({scrollTop: $flashContainer.offset().top},'slow')

      $timeout( 
        -> $('#flash').fadeOut(500); $timeout( (-> _clearOld($flashContainer)), 500),
        opts.keepUpThere || 2000
      )
      return true
    true


