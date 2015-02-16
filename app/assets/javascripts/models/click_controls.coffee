mod = angular.module('Models')
mod.factory 'ClickControls', ($timeout) ->

  class ClickControls

    @_placeEdits: (action, place_ids) ->
      alert(action + ' ' + place_ids)

    # INITIALIZE

    @initializePage: ->
      $('.edit-place, .edit-places').click -> 
        ClickControls._placeEdits( $(this).attr('id'), $(this).attr('data-place-ids') )

  return ClickControls