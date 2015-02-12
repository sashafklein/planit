angular.module("Common").directive 'bucketListPlaces', () ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "bucket_list_places.html"
    scope:
      place: '='

    link: (s, element) ->
  }