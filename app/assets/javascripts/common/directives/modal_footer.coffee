angular.module("Common").directive "modalFooter", (Modal) ->
  return {
    restrict: 'E'
    replace: true
    transclude: false
    template: '''
    <div class="modal-footer">
      <button class="planit-button cancel gray" data_dismiss="modal" type="button" ng_click='cancel()'>
        {{ cancelText }}
        <i class="fa fa-times pad-left"></i>
      </button>
      <button class='planit-button' ng-repeat='btn in extraButtons' ng-class='btn.class' ng-click='btn.clickMethod()' type='button' ng-if='extraButtons.length'>
        {{ btn.text }}
        <i ng-class='btn.iconClass'>
      </button>
    </div>
    '''
    scope: 
      extraButtons: '='
      cancelText: '@'
      cancelMethod: '&'

    link: (s, e) ->
      s.cancelText ||= 'Cancel'
      s.cancel = -> 
        if s.cancelMethod? then s.cancelMethod()() else new Modal('').hide()
        true
  }