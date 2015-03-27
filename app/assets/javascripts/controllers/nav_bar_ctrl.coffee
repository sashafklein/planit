angular.module("Controllers").controller 'NavBarCtrl', ($scope, BarExpander) ->
  s = $scope

  s.expandBar = () -> BarExpander.expandBar()