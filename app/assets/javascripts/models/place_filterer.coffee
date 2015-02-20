mod = angular.module('Models')
mod.factory 'PlaceFilterer', ($compile, $filter, QueryString) ->

  class PlaceFilterer

    @returnFiltered: (places) -> 
      filteredPlaces = $filter('filter')( places, PlaceFilterer._filterPlace )
      PlaceFilterer._showNumberFiltered((places.length - filteredPlaces.length))
      return filteredPlaces

    @_showNumberFiltered: (number) ->
      if $('#number_filtered').html() == ""
        if number > 0
          $('#number_filtered').html("-#{number}")
        else
          $('#number_filtered').html(null)

    @_filterPlace: (place) ->
      result = place
      # result = PlaceFilterer._been(result) if result
      # result = PlaceFilterer._loved(result) if result
      result = PlaceFilterer._metaCategory(result) if result
      result = PlaceFilterer._wifi(result) if result
      result = PlaceFilterer._query(result) if result
      # result = PlaceFilterer._open(result) if result

    @_metaCategory: (place) ->
      filters = PlaceFilterer._params().meta_categories
      if filters && filters.length > 0
        for category in place.meta_categories
          if filters.indexOf(category) != -1
            return place
        return null
      place

    @_wifi: (place) ->
      filter = PlaceFilterer._params().wifi
      if filter != ''
        return place if place.wifi == filter
        return null
      place

    @_query: (place) ->
      filter = PlaceFilterer._params().query
      if filter && typeof filter == 'string'
        filter = filter.toLowerCase()
        for name in place.names
          if name.toLowerCase().indexOf(filter) != -1
            return place
        return place if place.sublocality && place.sublocality.toLowerCase().indexOf(filter) != -1
        return place if place.locality && place.locality.toLowerCase().indexOf(filter) != -1
        return place if place.region && place.region.toLowerCase().indexOf(filter) != -1
        return place if place.country && place.country.toLowerCase().indexOf(filter) != -1
        for category in place.categories
          if category.toLowerCase().indexOf(filter) != -1
            return place
        return null
      place

    @_params: () -> 
      queryString = QueryString.paramString('q')
      filtersArray = QueryString.paramArray('f')
      params = { meta_categories: [], wifi: '', open: '', been: '', loved: '' }
      params.meta_categories.push "Food" if ( filtersArray.indexOf('food') != -1 )
      params.meta_categories.push "Drink" if ( filtersArray.indexOf('drink') != -1 )
      params.meta_categories.push "See" if ( filtersArray.indexOf('seedo') != -1 )
      params.meta_categories.push "Do" if ( filtersArray.indexOf('seedo') != -1 )
      params.meta_categories.push "Stay" if ( filtersArray.indexOf('stay') != -1 )
      params.meta_categories.push "Relax" if ( filtersArray.indexOf('relax') != -1 )
      params.meta_categories.push "Money" if ( filtersArray.indexOf('other') != -1 )
      params.meta_categories.push "Help" if ( filtersArray.indexOf('other') != -1 )
      params.meta_categories.push "Transit" if ( filtersArray.indexOf('other') != -1 )
      params.meta_categories.push "Shop" if ( filtersArray.indexOf('other') != -1 )
      params.meta_categories.push "Area" if ( filtersArray.indexOf('other') != -1 )
      params.meta_categories.push "Other" if ( filtersArray.indexOf('other') != -1 )
      params.wifi == true if ( filtersArray.indexOf('wifi') != -1 )
      # params.open == true if ( filtersArray.indexOf('open') != -1 )
      # params.been == false if ( filtersArray.indexOf('hide-been') != -1 )
      # params.loved == true if ( filtersArray.indexOf('loved') != -1 )
      return params

  return PlaceFilterer