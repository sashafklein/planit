mod = angular.module('Models')
mod.factory 'BasicOperators', ->

  class BasicOperators

    # Great JS/Coffeescript Sorting Method
    @dynamicSort = (property) ->
      sortOrder = 1
      if property[0] is "-"
        sortOrder = -1
        property = property.substr(1)
      (a, b) ->
        result = (if (a[property] < b[property]) then -1 else (if (a[property] > b[property]) then 1 else 0))
        result * sortOrder

    @commaAndJoin = (list, max=3) ->
      return null if !list || list.length == 0 || list.length > 5
      if list.length == 1
        list[0]
      else if list.length == 2 && max >= 2
        list.join(" & ")
      else if list.length == 3 && max >= 3
        [[list[0],list[1]].join(", "),list[2]].join(" & ")
      else if list.length == 4 && max >= 4
        [[list[0],list[1],list[2]].join(", "),list[3]].join(" & ")
      else if list.length == 5 && max >= 5
        [[list[0],list[1],list[2],list[3]].join(", "),list[4]].join(" & ")

  return BasicOperators