angular.module('Common').directive 'deferImage', ->
  restrict: 'A'
  link: (scope, element) ->
    element.css('opacity', 0)

    element.on 'load', ->
      element.animate({opacity: 1}, 200)
    