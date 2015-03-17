angular.module('Common').factory 'Collapsibles', (QueryString) ->

  class Collapsibles

    # @_params = [
    #   y, # year
    #   v, # view
    # ]

    @_current: (param) ->
      query = QueryString.get()[param] || ''
      _.compact(query.split("+"))

    @_set: ->
      for id in Collapsibles._current('y')
        Collapsibles._toggle( id )

    @_toggle: (id, page_loaded=false) ->
      $( "." + id ).toggleClass('collapsed')
      $( "#" + id ).toggleClass('collapsed-on')
      if page_loaded
        current = Collapsibles._current('y')
        if current.indexOf(id) == -1
          current.push id
        else
          current.splice( current.indexOf(id), 1 )
        QueryString.modify( y: current.join("+") )

    # INITIALIZE

    @initializePage: ->
      Collapsibles._set()
      $('.collapses').click -> Collapsibles._toggle( this.id, true )

  return Collapsibles
