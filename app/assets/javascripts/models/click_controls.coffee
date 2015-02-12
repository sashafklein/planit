mod = angular.module('Models')
mod.factory 'ClickControls', ($timeout) ->

  class ClickControls

    @placeEdits: (action, place_ids) ->
      alert(action + ' ' + place_ids)

  return ClickControls