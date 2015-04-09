angular.module('Common').factory 'QueryString', ($location) ->

  class QueryString

    # PUBLIC

    @get: -> $location.search()

    @reset: -> $location.search({})

    @set: (hash) -> if hash then $location.search(hash).replace() else QueryString.reset()

    @modify: (object) ->
      [newObj, clone] = [ {}, QueryString._clone( $location.search() ) ]

      _.forEach object, (v,k) ->
        newObj[k] = if (!k? || typeof(k) == 'string') then v else v.join(",")

      $location.search( QueryString._combine(clone, newObj) ).replace()

    # PRIVATE 

    @_clone: (search) -> 
      JSON.parse JSON.stringify $location.search()

    @_combine: (clone, newObj) ->
      _(clone).extend(newObj).pick( (v,k) -> v? ).value()

  return QueryString
