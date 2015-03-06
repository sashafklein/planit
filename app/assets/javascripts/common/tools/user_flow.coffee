angular.module('Common').factory 'UserFlow', () ->

  class UserFlow

    @_setCollapsibles: () ->
      $('.collapses').click( -> 
        $(".#{this.id}").toggleClass('collapsed')
        $(this).toggleClass('collapsed-on')
      )

    # INITIALIZE

    @initializePage: () ->
      UserFlow._setCollapsibles()

  return UserFlow
