###
on enter-press, calls function, even outside of form (unlike ng-submit)
Taken from: http://stackoverflow.com/questions/15417125/submit-form-on-pressing-enter-with-angularjs

%input{ type: 'text', ng_model: 'inputModel', ng_on_enter_key: 'doSomething()' }
###

angular.module('Common').directive 'ngOnEnterKey', (OnKey) ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->
      new OnKey(scope, 'ngOnEnterKey', 13).setBehavior(element, attrs)
  }