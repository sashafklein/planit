#= require_self
#= require common/common
#= require_tree ./models
#= require_tree ./modals
#= require_tree ./controllers
#= require angular-rails-templates
#= require_tree ./templates

# http://clintberry.com/2013/modular-angularjs-application-design/

planitModules = [
  'Common'
  'Models'
  'Controllers'
  'Services'
  'Modals'
  'SPA'
]

otherModules = ['leaflet-directive', 'templates']

angular.module(module, otherModules) for module in planitModules

@ngApp = angular.module( "ngApp", otherModules.concat(planitModules) )

@ngApp.config ($compileProvider, $locationProvider) ->
  # Prevent angular from marking links with a variety of protocols "unsafe"
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|webcal|mailto|file|tel):/)
  
  # Stop angular from prefixing all ng-changed URLs with a # sign
  $locationProvider.html5Mode(true)