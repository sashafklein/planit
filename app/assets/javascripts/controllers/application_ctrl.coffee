mod = angular.module('Controllers')
mod.controller "ApplicationCtrl", ($scope, ClickControls, Collapsibles, Bootstrap, Flashes, $rootScope, CurrentUser) ->
  
  # Universal to all users/non-users
  Bootstrap.initializePage()
  Collapsibles.initializePage()
  Flashes.initializePage()

  if CurrentUser.role != 'pending'
    ClickControls.initializePage()
