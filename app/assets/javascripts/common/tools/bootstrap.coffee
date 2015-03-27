angular.module('Common').factory 'Bootstrap', () ->

  class Bootstrap

    @_toggleDropDowns: () ->
      $('.dropdown-toggle').dropdown()
      $('.popover-toggle').popover({ html: true })

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

    # INITIALIZE

    @initializePage: () ->
      Bootstrap._clearInputs()
      Bootstrap._toggleDropDowns()
      Bootstrap._feedback()

  return Bootstrap
