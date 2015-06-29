angular.module("Directives").directive 'addNoteOnClick', (Modal, ErrorReporter, Flash) ->
  
  return {
    restrict: 'A'
    scope:
      objType: '@'
      objId: '@'

    link: (s, element, attrs) ->
      
      element.bind "click", (event) ->

        $('.loading-mask').show()
        s.modal = new Modal('addNote')

        if s.objType?.length && s.objId?.length
          s.modal.show({ objId: s.objId, objType: s.objType })
          $('.loading-mask').hide()
        else
          Flash.error("You must bookmark a place before adding a note for it.")
          $('.loading-mask').hide()
        
  }