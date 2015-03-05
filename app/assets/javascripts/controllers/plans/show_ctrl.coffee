mod = angular.module('Controllers')
mod.controller 'Plans.ShowCtrl', ($scope, Flash, $http, $q) ->

  $s = $scope
  $s.mapExpanded = false

  $s.contractOrExpandMap = ->
    $s.$root.mapExpanded = $s.mapExpanded = !$s.mapExpanded
