angular.module('Common').factory 'F', () ->
  average: (array) ->
    total = _(array).reduce (sum, element) -> 
      sum + element
    total / array.length