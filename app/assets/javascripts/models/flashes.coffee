mod = angular.module('Models')
mod.factory 'Flashes', ($timeout) ->

  class Flashes

    # INITIALIZE

    @initializePage: ->
      $('#flash').click ->
        $(this).hide()
      setTimeout (-> $('#flash').fadeOut('slow') ), 750

  return Flashes