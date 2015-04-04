angular.module("Common").directive 'addNoteOnClick', (Modal, ErrorReporter, Flash) ->
  
  return {
    restrict: 'A'
    scope:
      objectType: '@'
      objectId: '@'

    link: (s, element, attrs) ->

      element.bind "click", (event) ->

        s.modal = new Modal('addNote')

        if s.objectType?.length && s.objectId?.length
          s.modal.show({ objectId: s.objectId, objectType: s.objectType })
        else
          Flash.error("You must bookmark a place before adding a note for it.")

        
  }