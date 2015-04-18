###
on ShiftTab-press, calls function, even outside of form (unlike ng-submit)
Taken from: http://stackoverflow.com/questions/15417125/submit-form-on-pressing-ShiftTab-with-angularjs

%input{ type: 'text', ng_model: 'inputModel', ng_on_Shifttab_key: 'doSomething()' }
###

angular.module('Common').directive 'ngOnShiftTabKey', ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->

      element.bind "keyup", (event) ->

        if event.which is 9 && event.shiftKey #tab key with shift
          scope.$apply ->
            scope.$eval attrs.ngOnShiftTabKey,
              event: event
            return
          event.preventDefault()
  }