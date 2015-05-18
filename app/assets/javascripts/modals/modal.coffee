angular.module("Modals").directive 'modal', ($rootScope, Modal) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "modals/modal.html"

    link: (s, e) ->

      $rootScope.$watch 'modalData', ->
        return unless $rootScope.modalData
        
        s.data = $rootScope.modalData

        s.text = -> if s.data.error? then s.errorText() else s.loadingText()
        s.loadingText = -> if s.data?.text? then s.data.text else "Working on it..."
        s.errorText = -> if s.data?.text? then s.data.text else "Something's gone wrong! We've been notified."
        s.dismiss = -> new Modal(s.data.type).hide()

  }