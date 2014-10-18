#= require_self
#= require underscore-min
#= require ui-bootstrap-tpls.min
#= require plan
#= require common/common
#= require_tree ./models
#= require_tree ./controllers

# http://clintberry.com/2013/modular-angularjs-application-design/

planitModules = [
  'Common'
  'Models'
  'Controllers'
]

otherModules = [
  "ngRoute"
  "ui.bootstrap"
]

for module in planitModules
    angular.module(module, [])

@ngApp = angular.module("ngApp", otherModules.concat(planitModules))

@ngApp.config ($compileProvider) ->
  # Prevent angular from marking links with a variety of protocols "unsafe"
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|webcal|mailto|file|tel):/)