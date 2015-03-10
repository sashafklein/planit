angular.module('Common').factory 'UserFlow', (QueryString) ->

  class UserFlow

    @_currentCollapsibles: ->
      view = QueryString.get()['v'] || ''
      _.compact(view.split("+"))

    @_setCollapsibles: ->
      for id in UserFlow._currentCollapsibles()
        UserFlow._toggleCollapsibles( id )

    @_toggleCollapsibles: (id, set_query=false) ->
      $( "." + id ).toggleClass('collapsed')
      $( "#" + id ).toggleClass('collapsed-on')
      if set_query
        current = UserFlow._currentCollapsibles()
        if current.indexOf(id) == -1
          current.push id
        else
          current.splice( current.indexOf(id), 1 )
        QueryString.modify( v: current.join("+") )

    # INITIALIZE

    @initializePage: ->
      UserFlow._setCollapsibles()
      $('.collapses').click -> UserFlow._toggleCollapsibles( this.id, true )

  return UserFlow
