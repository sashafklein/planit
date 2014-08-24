###
on enter-press, calls function, even outside of form (unlike ng-submit)
Taken from: http://stackoverflow.com/questions/15417125/submit-form-on-pressing-enter-with-angularjs

%input{ type: 'text', ng_model: 'inputModel', ng_on_enter_key: 'doSomething()' }
###

angular.module('Common').directive 'ngOnEnterKey', ->
  (scope, element, attrs) ->
    element.bind "keydown keypress", (event) ->
      if event.which is 13 #enter key
        scope.$apply ->
          scope.$eval attrs.ngOnEnterKey,
            event: event
          return
        event.preventDefault()