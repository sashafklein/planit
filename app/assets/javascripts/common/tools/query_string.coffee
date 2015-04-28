angular.module('Common').factory 'QueryString', ($location) ->

  class QueryString

    # PUBLIC

    @get: -> $location.search()

    @reset: -> $location.search({})

    @set: (hash) -> 
      if hash && Object.keys(hash)?.length
        $location.search( hash ).replace()
        # $scope.$on '$routeUpdate', ->
        #   $scope.sort = $location.search().sort
        #   $scope.order = $location.search().order
        #   $scope.offset = $location.search().offset
      else
        QueryString.reset()

    @modify: (object) ->
      [newObj, clone] = [ {}, QueryString._clone( $location.search() ) ]

      _.forEach object, (v,k) ->
        newObj[k] = if (!k? || typeof(k) == 'string') then v else v.join(",")

      QueryString.set( QueryString._combine(clone, newObj) )

    # PRIVATE 

    @_clone: (search) -> 
      JSON.parse JSON.stringify $location.search()

    @_combine: (clone, newObj) ->
      _(clone).extend(newObj).pick( (v,k) -> v? ).value()

  return QueryString
