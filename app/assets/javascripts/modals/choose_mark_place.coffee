angular.module('Modals').directive 'chooseMarkPlace', (Mark, Modal, ErrorReporter, $timeout, Place) ->
  return { 
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'modals/choose_mark_place.html'
    scope:
      mark: '='

    link: (s, e) ->
      s.mark = Mark.generateFromJSON( s.mark ) unless s.mark.class? # Already generated

      s.edit = -> window.location.href = "/marks/#{s.mark.id}"
      
      s.categories = ( place ) -> place.categories.join(", ")

      s.cancel = -> 
        return unless confirm("Are you sure?")
        s.mark.destroy()
          .success -> s.confirm()
          .error -> ErrorReporter.fullSilent( response, 'chooseMarkPlace modal cancel()', { mark_id: s.mark.id })

      s.confirm = ( place_option_id ) -> 
        new Modal('').show({ loading: true, text: 'Saving new bookmark...' })
        s.mark.choose( place_option_id )
          .success (response) ->
            s.mark.place = response
            new Modal('').hide()
          .error (response) -> 
            new Modal('').hide()
            ErrorReporter.fullSilent( response, 'chooseMarkPlace modal confirm', { mark_id: s.mark.id } )

  }
