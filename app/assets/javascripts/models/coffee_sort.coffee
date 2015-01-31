mod = angular.module('Models')
mod.factory 'CoffeeSort', ->

  class CoffeeSort

    # Great JS/Coffeescript Sorting Method
    @dynamicSort = (property) ->
      sortOrder = 1
      if property[0] is "-"
        sortOrder = -1
        property = property.substr(1)
      (a, b) ->
        result = (if (a[property] < b[property]) then -1 else (if (a[property] > b[property]) then 1 else 0))
        result * sortOrder

  return CoffeeSort