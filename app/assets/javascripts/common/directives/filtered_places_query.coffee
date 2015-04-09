angular.module("Common").directive 'filteredPlacesQuery', (Mark, Place, $timeout, ErrorReporter, CurrentUser, Modal) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "filtered_places_query.html"
    scope:
      hideSearch: '&'

    link: (s, element) ->

  }