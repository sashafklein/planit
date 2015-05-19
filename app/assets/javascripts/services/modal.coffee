angular.module("Services").factory "Modal", ($rootScope, $timeout) ->

  class Modal

    constructor: (type) ->
      @_seed(type)
    
    show: (data) ->
      @_seed( @modalData.type )
      $rootScope.modalData = _.extend( @modalData, data )
      $timeout( (-> $('#planit-modal-new').modal('show')), 100)

    hide: -> 
      $rootScope.modalData = @modalData = null
      $('#planit-modal-new').modal('hide')
      true

    _seed: (type) -> @modalData = { type: type }

  return Modal