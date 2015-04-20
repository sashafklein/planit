###
on Tab-press, calls function, even outside of form (unlike ng-submit)
Taken from: http://stackoverflow.com/questions/15417125/submit-form-on-pressing-Tab-with-angularjs

%input{ type: 'text', ng_model: 'inputModel', ng_on_tab_key: 'doSomething()' }
###

angular.module('Common').directive 'ngOnTabKey', ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->
      new OnKey(scope, 'ngOnTabKey', 9).setBehavior(element, attrs)
  }