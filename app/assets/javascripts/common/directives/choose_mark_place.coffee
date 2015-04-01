angular.module('Common').directive 'chooseMarkPlace', (Mark, Modal, ErrorReporter, $timeout) ->
  return { 
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'choose_mark_place.html'
    scope:
      mark: '='
      headerTitle: '@'

    link: (s, e) ->

      s.place_options = s.mark.place_options if s.mark

      s.markObj = new Mark({ id: s.mark.id })
      s.edit = -> window.location.href = "/marks/#{s.mark.id}"
      
      s.currentImageIndex = 0
      s.backgroundImage = ( place ) ->
        if place.images.length > 0
          "background-image: url('#{place.images[currentImageIndex].url}')"
      s.nextImage = ( place ) -> 
        if place.images.length > 0
          s.currentImageIndex = (s.currentImageIndex + 1) %% (place.images.length)
      s.categories = ( place ) -> place.categories.join(", ")

      s.cancel = -> 
        # areYouSure?
        s.markObj.destroy()
          .success -> s.confirm()
          .error -> ErrorReporter.report({ mark_id: s.mark.id, context: 'Trying to delete a mark in chooseMarkPlace modal', api_path: s.markObj.objectPath() })

      s.confirm = ( place_option_id ) -> 
        new Modal('').show({ loading: true })
        s.markObj.choose( place_option_id )
          .success (response) ->
            s.mark.place = response
            new Modal('addMarkPlace').show({ mark: s.mark, confirm: true })
          .error -> 
            new Modal('').hide()
            ErrorReporter.report({ mark_id: s.mark.id, context: 'Trying to choose a placeoption in chooseMarkPlace modal', api_path: s.markObj.objectPath() })

  }
