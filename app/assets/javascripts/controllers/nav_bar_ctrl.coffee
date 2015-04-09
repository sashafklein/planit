angular.module("Controllers").controller 'NavBarCtrl', ($scope, BarExpander, QueryString) ->
  s = $scope

  s.expandBar = () -> BarExpander.expandBar()
  s.home = () -> QueryString.reset()