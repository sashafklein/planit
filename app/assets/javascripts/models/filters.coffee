mod = angular.module('Models')
mod.factory 'Filters', (QueryString, UserLocation) ->

  class Filters

    @setInitialFilters: ->
      filtersString = QueryString.get()['f'] || ''
      filtersArray = _.compact( filtersString.split("+") )
      for filter in filtersArray
        $(".filter-dropdown-menu-checkbox##{filter}").prop('checked',true)
      Filters._toggleClearAll(true) if filtersArray.length > 0

    @toggleFilter: (filter, status) ->
      filtersString = QueryString.get()['f'] || ''
      filtersArray = _.compact( filtersString.split("+") )
      if filtersArray.indexOf(filter) != -1
        filtersArray.splice( filtersArray.indexOf(filter), 1 )
        Filters._toggleClearAll(false) if filtersArray.length == 0
        QueryString.modify(f:filtersArray.join('+'))
      else
        filtersArray.push( filter )
        Filters._toggleClearAll(true) if filtersArray.length == 1
        QueryString.modify(f:filtersArray.join('+'))

    @_clearAll: (bool) ->
      $('.filter-dropdown-menu-checkbox').prop('checked',false)
      QueryString.modify(f:null)
      Filters._toggleClearAll(false)

    @_toggleClearAll: (bool) ->
      if bool
        $('.apply-filters').hide(0)
        $('.clear-all-filters').show(0)
        $('.filter-button').addClass('on')
        $('.filter-or-number').removeClass('fa fa-sliders fa-lg')
        $('.filter-or-number').addClass('show-numbers')
      else
        $('.clear-all-filters').hide(0)
        $('.apply-filters').show(0)
        $('.filter-button').removeClass('on')
        $('.filter-or-number').addClass('fa fa-sliders fa-lg')
        $('.search-and-filter-wrap').removeClass('open')
        $('.filter-or-number').removeClass('show-numbers')
        $('#number_filtered').html(null) #remove when place_filterer working?

    # INITIALIZE

    @initializePage: ->
      if $('.filter-dropdown-menu-checkbox').val() #check to see if dropdowns are there
        Filters.setInitialFilters()
        $('.filter-dropdown-menu-checkbox').click -> Filters.toggleFilter( $(this).attr('id'), $(this).prop('checked') )
        $('.filter-dropdown-menu-nearby').click -> UserLocation.showPositionQueryString(UserLocation.latLong)
        $('.clear-all-filters').click -> Filters._clearAll()

  return Filters