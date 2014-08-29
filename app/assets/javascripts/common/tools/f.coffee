angular.module('Common').factory 'F', () ->
  
  avg: (array) -> @sum(array) / array.length

  avgOfExtremes: (array) -> @avg( [_.min(array), _.max(array)] )

  sum: (array) -> _(array).reduce( (sum, element) -> sum + element )