###
on esc-press, calls function, even outside of form (unlike ng-submit)
Taken from: http://stackoverflow.com/questions/15417125/submit-form-on-pressing-enter-with-angularjs

%input{ type: 'text', ng_model: 'inputModel', ng_on_esc_key: 'doSomething()' }
###

angular.module("Directives").directive 'ngOnEscKey', ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->

      element.bind "keydown keypress", (event) ->

        if event.which is 27 #escape key
          scope.$apply ->
            scope.$eval attrs.ngOnEscKey,
              event: event
            return
          event.preventDefault()
  }