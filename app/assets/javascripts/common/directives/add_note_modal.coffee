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
      objectId: '='
      objectType: '='

    link: (s, e) ->

      s.submit = ->
        
        return Flash.error("Please write a note before submitting") unless s.text?.length
        Note.create({ note: { object_id: s.objectId, object_type: s.objectType, body: s.text } })
          .success (response) ->
            new Modal('').hide()
          .error (response) ->
            ErrorReporter.report({ context: "Failed note addition in modal", object_id: s.objectId, object_type: s.objectType, text: s.text })
            new Modal('').hide()

      s.extraButtons = [
        { class: "planit-button neon", text: 'Submit', iconClass: 'fa fa-check pad-left', clickMethod: s.submit }
      ]
  }
