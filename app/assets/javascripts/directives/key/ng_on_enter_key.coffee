###
on enter-press, calls function, even outside of form (unlike ng-submit)
Taken from: http://stackoverflow.com/questions/15417125/submit-form-on-pressing-enter-with-angularjs

%input{ type: 'text', ng_model: 'inputModel', ng_on_enter_key: 'doSomething()' }
###

angular.module('Common').directive 'ngOnEnterKey', ($timeout) ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->
      scope.keyNumber = 13
      scope.directiveName = 'ngOnEnterKey'
      scope.resetRan = -> $timeout( (-> scope.ran = false ), 100)

      element.bind "keydown keypress", (event) ->
        return unless event.which is scope.keyNumber
        $timeout( 
          ->
            if !scope.ran
              scope.ran = true
              scope.$apply ->
                scope.$eval attrs[scope.directiveName],
                  event: event
                return
              event.preventDefault()
              scope.resetRan()
          ,
          100
        )
  }