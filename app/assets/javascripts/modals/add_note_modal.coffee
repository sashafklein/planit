angular.module('Modals').directive 'addNoteModal', (Note, Modal, ErrorReporter, Flash) ->
  return { 
    restrict: 'E'
    transclude: false
    replace: true
    template: '''
    <div class='modal-directive-wrapper'>
      <div class='add-trip-section'>
        <modal-header header-title='Add a Section'></modal-header>
        <div class='modal-body'>
          <textarea type='text' ng-model='text' style='width:100%;resize:none'></textarea>
        </div>
        <modal-footer extra-buttons='extraButtons'/></modal-footer>
      </div>
    </div>
    '''
    scope:
      data: '='

    link: (s, e) ->

      s.submit = ->
        debugger
      s.extraButtons = [
        { class: "planit-button neon", text: 'Submit', iconClass: 'fa fa-check pad-left', clickMethod: s.submit }
      ]
  }
