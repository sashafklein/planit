mod = angular.module('Models')
mod.directive 'mapFilterDropdown', (QueryString, UserLocation) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: 'place_filter_dropdown.html'

    link: (s, elem) ->

      s.filters = {}

      s._filterString = -> 
        vals = _(s.filters).map( (v,k) -> if v then k else null ).compact().value()
        if vals.length then vals.join(",") else null

      s._initFilters = ->
        filters = _.compact QueryString.get()['f']?.split(",")

        _(filters).forEach( (v, k) => s.filters[v] = true ).value()

      s.filtersSet = -> _.some(s.filters, (v) -> v )

      $('.filter-dropdown-menu').click (e) -> e.stopPropagation()

      s._initFilters()

      s.filterList = [
        { slug: 'loved', name: 'Only Most Loved', icon: "fa.fa-heart" }
        { slug: 'been', name: 'Hide Already Visited', icon: "fa.fa-check-square" }
        { divider: true }
        { slug: 'food', name: 'Food/Markets', icon: 'icon-local-restaurant' }
        { slug: 'drink', name: 'Drink/Nightlife', icon: 'icon-local-bar' }
        { slug: 'seedo', name: 'See/Do', icon: 'icon-directions-walk' }
        { slug: 'stay', name: 'Stay', icon: 'icon-home' }
        { slug: 'relax', name: 'Relax', icon: 'icon-drink' }
        { divider: true }
        { slug: 'open', name: 'Open Only', icon: 'fa.fa-clock' }
        { slug: 'wifi', name: 'Wifi Only', icon: 'fa.fa-wifi' }
      ]

      s.clearFilters = () -> s.filters = {}
      window.sf = s
      s.$watch('filters', ( 
        -> 
          QueryString.modify( f: s._filterString() ) )
        , 
        true 
      )
  }