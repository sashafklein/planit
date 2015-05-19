angular.module("Services").service 'Spinner', ->

  class Spinner
    @show: -> 
      $(".loading-mask").show()
      return

    @hide: ->
      $(".loading-mask").hide()
      return

  return Spinner