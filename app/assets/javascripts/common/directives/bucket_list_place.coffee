angular.module("Common").directive 'bucketListPlace', (CurrentUser) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "bucket_list_place.html"
    scope:
      m: '=?'
      item: '=?'
      place: '='

    link: (s, element) ->
      s.userId = CurrentUser.id

  }