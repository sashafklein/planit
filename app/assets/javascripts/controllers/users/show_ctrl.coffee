mod = angular.module('Controllers')
mod.controller 'Users.ShowCtrl', ($scope, Item) ->
  $s = $scope

  # $s.loadItems = -> Item.all().success (response) -> $s.items = Item.generateFromJSON( response )