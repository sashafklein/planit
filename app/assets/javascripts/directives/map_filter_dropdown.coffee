mod = angular.module('Models')
mod.directive 'mapFilterDropdown', (QueryString) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'map_filter_dropdown.html'
    scope: 
      places: '='

    link: (s, elem) ->

      s.filters = {}

      s._filterString = -> 
        vals = _(s.filters).map( (v,k) -> if v then k else null ).compact().value()
        if vals.length then vals.join(",") else null

      s._initFilters = ->
        filters = _.compact QueryString.get()['f']?.split(",")

        _.forEach(filters,  (v, k) => s.filters[v] = true )

      s.filtersSet = -> _.some(s.filters, (v) -> v )

      s.filterList = [
        { slug: 'loved', name: 'Only Most Loved', icon: "fa.fa-heart" }
        { slug: 'been', name: 'Hide Already Visited', icon: "fa.fa-check-square" }
        { divider: true }
        { slug: 'food', name: 'Food/Markets', icon: 'md-local-restaurant' }
        { slug: 'drink', name: 'Drink/Nightlife', icon: 'md-local-bar' }
        { slug: 'seedo', name: 'See/Do', icon: 'md-directions-walk' }
        { slug: 'stay', name: 'Stay', icon: 'md-home' }
        { slug: 'relax', name: 'Relax', icon: 'md-drink' }
        { divider: true }
        { slug: 'open', name: 'Open Only', icon: 'fa.fa-clock' }
        { slug: 'wifi', name: 'Wifi Only', icon: 'fa.fa-wifi' }
      ]

      s.clearFilters = () -> s.filters = {}
      
      # INIT

      # Click on the div doesn't automatically close it
      $('.filter-dropdown-menu').click (e) -> e.stopPropagation()
      s._initFilters()

      # On filter change, update the QueryString
      s.$watch('filters', ( 
        -> 
          QueryString.modify( f: s._filterString() ) )
        , 
        true 
      )
  }