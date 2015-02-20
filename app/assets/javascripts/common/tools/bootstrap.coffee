angular.module('Common').factory 'Bootstrap', (UserLocation) ->

  class Bootstrap

    @_toggleDropDowns: () ->
      $('.dropdown-toggle').dropdown()
      $('.popover-toggle').popover({ html: true })

    @_toggleModals: () ->
      $('#planit-modal').modal()
      $('#planit-modal').on 'shown.bs.modal', -> $('#planit-modal').focus()
      $('#planit-modal-new').on 'shown.bs.modal', -> UserLocation.showPositionInNewModal(UserLocation.latLong)

    @_clearInputs: () ->
      $('.input-with-clear').keyup -> $(this).next().toggle Boolean($(this).val())
      $('.clear-input-button').toggle Boolean($('.input-with-clear').val())
      $('.clear-input-button').click -> $(this).prev().val('').focus(); $(this).hide()

    # INITIALIZE

    @initializePage: () ->
      Bootstrap._clearInputs()
      Bootstrap._toggleModals()
      Bootstrap._toggleDropDowns()

  return Bootstrap
