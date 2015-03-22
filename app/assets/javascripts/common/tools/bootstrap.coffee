angular.module('Common').factory 'Bootstrap', (UserLocation) ->

  class Bootstrap

    @_toggleDropDowns: () ->
      $('.dropdown-toggle').dropdown()
      $('.popover-toggle').popover({ html: true })

    @_toggleModals: () ->
      $('#planit-modal-new').on 'shown.bs.modal', -> UserLocation.showPositionInNewModal(UserLocation.latLong)

    @_clearInputs: () ->
      $('.input-with-clear').keyup -> $(this).next().toggle Boolean($(this).val())
      $('.clear-input-button').toggle Boolean($('.input-with-clear').val())
      $('.clear-input-button').click -> $(this).prev().val('').focus(); $(this).hide()

    @_feedback: () ->
      $('input.happiness').on 'change', ->
        $('.happiness-feedback').hide('0')
        if $('input[name=happiness]:checked').val() > 7
          $('.loving-feedback').show('fast')
        else
          $('.improve-feedback').show('fast')
        $('#planit-modal-submit-feedback').removeAttr('disabled')

    @_resetNewModal: () ->
      $('#planit-modal-new .loading, #planit-modal-new .confirm, #planit-modal-new .choose, #planit-modal-new .error').hide()
      $('#planit-modal-new .initiate').show()
      $('#planit-modal-new .new-pin-nearby, #planit-modal-new .new-pin-query').val(null)

    # INITIALIZE

    @initializePage: () ->
      Bootstrap._clearInputs()
      Bootstrap._toggleModals()
      Bootstrap._toggleDropDowns()
      Bootstrap._feedback()

    $('#planit-modal-new .close, #planit-modal-new .cancel').on 'click', -> Bootstrap._resetNewModal()

  return Bootstrap
