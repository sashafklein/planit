mod = angular.module('Models')
mod.factory 'ClickControls', ($timeout) ->

  class ClickControls

    @placeEdits: (action, place_ids) ->
      alert('Post-beta ;-) ')
      # if _(['tag','note']).contains(action)
      #   $("#planit-modal-#{action}").modal()
      #   $('#places_to_control').val(place_ids)
      # else if _(['save']).contains(action) && place_ids.length > 1
      #   alert("Save All #{place_ids.length}?")
      # else if _(['delete']).contains(action)
      #   alert("Are You Sure?")
      # else if _(['save','been','not','love','unlove']).contains(action)
      #   alert(action + " " + place_ids)

    # INITIALIZE

    @initializePage: ->
      $('.edit-place, .edit-places').click -> 
        ClickControls.placeEdits( $(this).attr('id'), $(this).attr('data-place-ids') )

  return ClickControls