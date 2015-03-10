mod = angular.module('Controllers')
mod.controller "ApplicationCtrl", ($scope, ClickControls, SearchBar, UserFlow, QueryString, Bootstrap, UserLocation, Filters, Flashes, $rootScope) ->

  # Universal to all users/non-users

  UserLocation.initializePage()
  Bootstrap.initializePage()
  UserFlow.initializePage()
  Flashes.initializePage()

  # if Current_User_Is_Active

  ClickControls.initializePage()
  SearchBar.initializePage()
  Filters.initializePage()
