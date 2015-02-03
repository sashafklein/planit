mod = angular.module('Controllers')
mod.controller 'Plans.ShowCtrl', ($scope, Flash, $http, $q) ->

  $s = $scope
  $s.mapExpanded = false

  $s.contractOrExpandMap = ->
    $s.mapExpanded = !$s.mapExpanded
