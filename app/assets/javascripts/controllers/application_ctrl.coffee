mod = angular.module('Controllers')
mod.controller "ApplicationCtrl", ($scope, ClickControls, SearchBar, UserFlow, QueryString, Bootstrap, UserLocation, Filters, Flashes, $rootScope) ->

  # Universal to all users/non-users

  UserLocation.initializePage() # if current_user_is_active
  Bootstrap.initializePage()
  UserFlow.initializePage()
  Flashes.initializePage()

  # if Current_User_Is_Active

  ClickControls.initializePage()
  SearchBar.initializePage()
  QueryString.initializePage()
  Filters.initializePage()
