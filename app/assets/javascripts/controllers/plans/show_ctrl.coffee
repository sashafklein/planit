mod = angular.module('Controllers')
mod.controller 'Plans.ShowCtrl', ($scope, Flash, $http, $q, Path) ->

  $s = $scope