###
on Tab-press, calls function, even outside of form (unlike ng-submit)
Taken from: http://stackoverflow.com/questions/15417125/submit-form-on-pressing-Tab-with-angularjs

%input{ type: 'text', ng_model: 'inputModel', ng_on_tab_key: 'doSomething()' }
###

angular.module("Directives").directive 'ngOnTabKey', ($timeout)->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->
      scope.keyNumber = 9
      scope.directiveName = 'ngOnTabKey'
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