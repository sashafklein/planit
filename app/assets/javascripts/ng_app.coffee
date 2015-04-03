#= require_self
#= require common/common
#= require_tree ./models
#= require_tree ./controllers

# http://clintberry.com/2013/modular-angularjs-application-design/

planitModules = [
  'Common'
  'Models'
  'Controllers'
  'Services'
]

otherModules = [
]

for module in planitModules
    angular.module(module, ["leaflet-directive"]) #, ['angular.filter']

@ngApp = angular.module("ngApp", otherModules.concat(planitModules))

@ngApp.config ($compileProvider, $locationProvider) ->
  # Prevent angular from marking links with a variety of protocols "unsafe"
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|webcal|mailto|file|tel):/)
  
  # Stop angular from prefixing all ng-changed URLs with a # sign
  $locationProvider.html5Mode(false)