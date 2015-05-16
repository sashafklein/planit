angular.module('Modals').directive 'modalHeader', (Modal) ->
  return { 
    replace: true
    transclude: false
    template: '''
      <div class='modal-header' >
        <button class='close' aria-label='Close' ng-click='dismiss()' type="button">
          <span aria-hidden="true">×</span>
        </button>
        <h4 class='modal-title'>{{ headerTitle }}</h4>
      </div>
    '''
    scope: 
      headerTitle: '@'
    link: (s, e) ->
      s.dismiss = -> new Modal('').hide()
  }
