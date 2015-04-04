mod = angular.module('Controllers')
mod.controller 'Plans.ShowCtrl', ($scope, Flash, ErrorReporter, Plan) ->

  $s = $scope
  $s.mapExpanded = false

  $s.contractOrExpandMap = ->
    $s.$root.mapExpanded = $s.mapExpanded = !$s.mapExpanded

  $s.unwrappedPlaces = []

  $s.loadPlaces = (id) -> 
    $s.planId = id
    Plan.findPlaces($s.planId)
      .success (response) ->
        $s.places = response
        $s.loaded = true
      .error () ->
        ErrorReporter.report({context: 'in Plans.ShowCtrl', plan_id: s.planId}, "Something went wrong loading the map! We've been notified.")