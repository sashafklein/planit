## In an angular file, just include the module and call like so:
##
##    # This will create a regular top-of-page flash
##    Flash.success("You've been successful!")
##
##    # This will create a flash in a specified class/id
##    Flash.error("You failed!", "#specific-flash-id")

angular.module("Common").factory 'Flash',  () ->
  alert_selector = '.flash-alert'

  _flashContainer = (location) ->
    if location && location.length > 0
      flash_container = $(location)
    # default flash to top of page
    else 
      flash_container = $('#flash')

  _clearErrors = ($flashContainer) ->
    # remove previous flashes in container
    if $(alert_selector).length > 0
      $flashContainer.find(alert_selector).remove() 

  clear: (location = null) ->
     _clearErrors(_flashContainer(location))

  error: (content, location = null) ->
    @new('error', content, location)

  success: (content, location = null) ->
    @new('success', content, location)

  notice: (content, location = null) ->
    @new('notice', content, location)

  warning: (content, location = null) ->
    @new('warning', content, location)  

  new: (type, content, location = null) ->
    $ ->
      $flashContainer = _flashContainer(location)
      _clearErrors($flashContainer)

      $flashContainer.append "<div id='flash'><div class='flash-alert' id='flash_#{type}'>#{content}</div></div>"

      $('html,body').animate({scrollTop: $flashContainer.offset().top},'slow')

