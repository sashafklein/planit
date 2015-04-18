###
on Tab-press, calls function, even outside of form (unlike ng-submit)
Taken from: http://stackoverflow.com/questions/15417125/submit-form-on-pressing-Tab-with-angularjs

%input{ type: 'text', ng_model: 'inputModel', ng_on_tab_key: 'doSomething()' }
###

angular.module('Common').directive 'ngOnTabKey', ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->

      element.bind "keydown keypress", (event) ->

        if event.which is 9 && !event.shiftKey #tab key no shift
          scope.$apply ->
            scope.$eval attrs.ngOnTabKey,
              event: event
            return
          event.preventDefault()
  }