angular.module("Common").directive 'modal', ($rootScope, Modal) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "modal.html"

    link: (s, e) ->

      $rootScope.$watch 'modalData', ->
        return unless $rootScope.modalData
        
        s.data = $rootScope.modalData

        s.title = ->  
          switch s.data.type
            when 'addPin' then "Add New Pin"
            else ''

        # s.confirmButton = ( callback ) ->
        #   [{ class: "planit-button neon", text: 'Yes', clickMethod: 'callback()' }]

        s.loadingText = ->
          if s.data.loading == 'longer'
            "Working on it. This may take a while..."
          else
            "Working on it..."

        s.dismiss = -> new Modal(s.data.type).hide()

  }