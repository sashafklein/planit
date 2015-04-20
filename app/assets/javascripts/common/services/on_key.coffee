angular.module("Common").factory 'OnKey', ($timeout) ->

  class OnKey

    constructor: (scope, attrName, keyNumber) ->
      @scope = scope
      @attrName = attrName
      @keyNumber = keyNumber
      @ran = false
    
    resetRan: -> $timeout( (-> @ran = false ), 100 )

    setBehavior: (element, attrs) ->
      context = @
      element.bind "keydown keypress", (event) ->
        return unless event.which is context.keyNumber
        $timeout( 
          ->
            if !context.ran
              context.ran = true
              context.scope.$apply ->
                context.scope.$eval attrs.ngOnEnterKey,
                  event: event
                return
              event.preventDefault()
              context.resetRan()
          ,
          100
        )

  return OnKey