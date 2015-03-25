angular.module('Common').directive 'bookmarkPlace', (Mark, Modal, ErrorReporter) ->
  return { 
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'bookmark_place.html'
    scope:
      mark: '='
      title: '@'

    link: (s, e) ->
      
      s.place = s.mark.place

      s.currentImageIndex = 0
      s.categories = -> s.place.categories.join(", ")
      s.edit = -> window.location.href = "/marks/#{s.mark.id}"
      
      s.nextImage = -> s.currentImageIndex = (s.currentImageIndex + 1) %% (s.place.images.length)

      s.cancel = -> 
        markObj = new Mark({ id: s.mark.id })

        markObj.destroy()
          .success -> s.confirm()
          .error -> ErrorReporter.report({ mark_id: s.mark.id, context: 'Trying to delete a mark in bookmarkPlace modal', api_path: markObj.objectPath() })

      s.confirm = -> new Modal('').hide()

      s.extraButtons = [
        { class: "planit-button blue", text: 'Edit', iconClass: 'fa fa-pencil pad-left', clickMethod: s.edit }
        { class: "planit-button neon", text: 'Confirm & Save', iconClass: 'fa fa-check pad-left', clickMethod: s.confirm }
      ]

  }
