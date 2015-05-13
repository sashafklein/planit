angular.module('Modals').directive 'viewMarkPlace', (Mark, Modal, ErrorReporter, $timeout) ->
  return { 
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'modals/view_mark_place.html'
    scope:
      place: '='
      headerTitle: '@'

    link: (s, e) ->

      s.categories = -> s.place.categories.join(", ")
      s.edit = -> window.location.href = "/places/#{s.place.id}"
      
      s.currentImageIndex = 0
      s.nextImage = -> s.currentImageIndex = (s.currentImageIndex + 1) %% (s.place.images.length)

      s.cancel = -> new Modal('').hide()

  }
