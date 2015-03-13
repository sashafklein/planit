angular.module('Common').factory 'F', () ->
  
  avg: (array) -> @sum(array) / array.length

  avgOfExtremes: (array) -> @avg( [_.min(array), _.max(array)] )

  sum: (array) -> _(array).reduce( (sum, element) -> sum + element )

  within: (array, value) -> 
    [first, second] = array
    Math.max(first, second) > value && Math.min(first, second) < value

  stagger: (callback, timeoutLength, xTimes, unlessMethod, doOnFailure) ->

    delay = (callback, timeoutLength, xTimes, unlessMethod, doOnFailure) ->
      if xTimes == 0
        doOnFailure?()
      else if !unlessMethod?()
        callback()
        setTimeout (-> delay(callback, timeoutLength, xTimes - 1, unlessMethod) ), timeoutLength 
    
    delay(callback, timeoutLength, xTimes, unlessMethod)