mod = angular.module('Controllers')
mod.controller "ApplicationCtrl", (ClickControls, SearchBar, QueryString, Bootstrap, UserLocation) ->

  ClickControls.initializePage()
  SearchBar.initializePage()
  QueryString.initializePage()
  Bootstrap.initializePage()
  UserLocation.initializePage()