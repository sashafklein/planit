mod = angular.module('Controllers')
mod.controller "ApplicationCtrl", ($scope, ClickControls, Collapsibles, Bootstrap, UserLocation, Filters, Flashes, $rootScope, CurrentUser) ->

  # Universal to all users/non-users

  UserLocation.initializePage() # if current_user_is_active
  Bootstrap.initializePage()
  Collapsibles.initializePage()
  Flashes.initializePage()

  if CurrentUser.role != 'pending'
    ClickControls.initializePage()
    Filters.initializePage()
