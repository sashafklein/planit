mod = angular.module('Models')
mod.factory 'PlaceFilterer', ($filter) ->

  class PlaceFilterer

    constructor: (queryHash) ->
      @queryHash = @_roundOut queryHash

    returnFiltered: (places) -> 
      return [] unless places
      filteredPlaces = $filter('filter')( places, ( (place) => @_filterPlace(place) ) )
      filteredPlaces

    _filterPlace: (place) ->
      [context, filters] = [@, [ '_metaCategoryFilter', '_wifiFilter', '_queryFilter' ]] # @_been, @_loved, @_open
      runFilter = (place, filterMethod) => if place then context[filterMethod](place) else null
      _(filters).reduce( runFilter, place )

    _metaCategoryFilter: (place) ->
      return place unless (filters = @queryHash.meta_categories)?.length
      if _(filters).some( (cat) -> _([place.meta_category]).includes(cat) ) then place else null

    _wifiFilter: (place) ->
      return place unless filter = @queryHash.wifi?
      if place.wifi == filter then place else null

    _queryFilter: (place) ->
      return place unless (filter = @queryHash.q)?.toLowerCase()

      areaTypes = _(['sublocality', 'locality', 'region', 'country']).map( (at) => place[at] ).compact.value()

      anyMatches = _([place.names, areaTypes, place.categories]).some( (possibleMatch) => return place if @_containsFilter(possibleMatch, filter) )
      if anyMatches then place else null

    _containsFilter: (collection, filter) -> _(collection).some( (val) -> val.toLowerCase().indexOf(filter) != -1 )
    
    _roundOut: (qHash) ->
      newObj = _({ meta_categories: [], wifi: null, open: null, been: null, loved: null }).extend(qHash).value()

      if newObj.f
        for val in newObj.f.split(",")
          if val == "seedo"
            newObj.meta_categories.push("See", "Do", "Shop")
          else if val == "other"
            newObj.meta_categories.push("Transit", "Area", "Help", "Money", "Other")
          else if val == 'wifi'
            newObj.wifi = true    
          else
            newObj.meta_categories.push( @_capitalize(val) )

      newObj

    _capitalize: (word) -> word.substr(0, 1).toUpperCase() + word.substr(1)

  return PlaceFilterer