angular.module('Common').directive 'bookmarkPlace', (Mark, Modal, ErrorReporter, $timeout) ->
  return { 
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'bookmark_place.html'
    scope:
      mark: '='
      initiate: '='
      headerTitle: '@'

    link: (s, e) ->

      s.place = s.mark.place if s.mark

      $timeout(-> $(".initiate input#primary").focus() if $(".initiate input#primary") && s.initiate )

      s.categories = -> s.place.categories.join(", ")
      s.edit = -> window.location.href = "/marks/#{s.mark.id}"
      
      s.currentImageIndex = 0
      s.nextImage = -> s.currentImageIndex = (s.currentImageIndex + 1) %% (s.place.images.length)

      s.cancel = -> 
        markObj = new Mark({ id: s.mark.id })
        markObj.destroy()
          .success -> s.confirm()
          .error -> ErrorReporter.report({ mark_id: s.mark.id, context: 'Trying to delete a mark in bookmarkPlace modal', api_path: markObj.objectPath() })

      s.confirm = -> new Modal('').hide()

      s.extraButtons = [
        { class: "planit-button blue", text: 'Double-Check', iconClass: 'fa fa-pencil pad-left', clickMethod: s.edit }
        { class: "planit-button neon", text: 'Save', iconClass: 'fa fa-check pad-left', clickMethod: s.confirm }
      ]

  }
