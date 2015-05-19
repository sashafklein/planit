angular.module("Directives").directive 'bucketListPlace', (CurrentUser, MetaCategory) ->

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

      s.colorClass = (meta_category) -> MetaCategory.colorClass( meta_category )

  }