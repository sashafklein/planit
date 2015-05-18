angular.module('Modals').directive 'chooseMarkPlace', (Mark, Modal, ErrorReporter, $timeout, Place) ->
  return { 
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'modals/choose_mark_place.html'
    scope:
      data: '='

    link: (s, e) ->
      s.mark = if s.data.mark?.class then s.data.mark else Mark.generateFromJSON s.data.mark

      s.edit = -> window.location.href = "/marks/#{s.mark.id}"
      
      s.categories = ( place ) -> place.categories.join(", ")

      s.cancel = -> 
        return unless confirm("Are you sure?")
        s.data.destroy( s.mark , s._hide )

      s.confirm = ( place_option_id ) -> 
        new Modal('').show({ loading: true, text: 'Saving new bookmark...' })
        s.data.choose( s.mark, place_option_id, s._hide )

      s._hide = -> new Modal('').hide()
      window.po = s
  }
