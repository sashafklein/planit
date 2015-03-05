mod = angular.module('Controllers')
mod.controller "ApplicationCtrl", (ClickControls, SearchBar, UserFlow, QueryString, Bootstrap, UserLocation, Filters, Tags, Flashes) ->

  # Universal to all users/non-users

  UserLocation.initializePage()
  Bootstrap.initializePage()
  UserFlow.initializePage()
  Flashes.initializePage()

  # if Current_User_Is_Active

  ClickControls.initializePage()
  SearchBar.initializePage()
  QueryString.initializePage()
  Filters.initializePage()
  Tags.initializePage()

