angular.module('Common').directive 'addNoteModal', (Note, Modal, ErrorReporter, Flash) ->
  return { 
    restrict: 'E'
    transclude: false
    replace: true
    template: '''
    <div class='modal-directive-wrapper'>
      <div class='add-note'>
        <modal-header header-title='Add a note'></modal-header>
        <div class='modal-body'>
          <textarea type='text' ng-model='text' style='width:100%;resize:none'></textarea>
        </div>
        <modal-footer extra-buttons='extraButtons'/></modal-footer>
      </div>
    </div>
    '''
    scope:
      objId: '='
      objType: '='

    link: (s, e) ->

      s.submit = ->
        
        return Flash.error("Please write a note before submitting") unless s.text?.length
        Note.create({ note: { obj_id: s.objId, obj_type: s.objType, body: s.text } })
          .success (response) ->
            new Modal('').hide()
          .error (response) ->
            ErrorReporter.report({ context: "Failed note addition in modal", obj_id: s.objId, obj_type: s.objType, text: s.text })
            new Modal('').hide()

      s.extraButtons = [
        { class: "planit-button neon", text: 'Submit', iconClass: 'fa fa-check pad-left', clickMethod: s.submit }
      ]
  }
