angular.module("Controllers").controller 'launchTopSearch', ($scope, BarExpander) ->
  s = $scope

  s.expandBar = () -> BarExpander.expandBar()