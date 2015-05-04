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

      s.colorClass = (meta_category) ->
        switch meta_category
          when 'Area' then 'yellow'
          when 'See' then 'green'
          when 'Do' then 'bluegreen'
          when 'Relax' then 'turqoise'
          when 'Stay' then 'blue'
          when 'Drink' then 'purple'
          when 'Food' then 'magenta'
          when 'Shop' then 'pink'
          when 'Help' then 'orange'
          when 'Other' then 'gray'
          when 'Transit' then 'gray'
          when 'Money' then 'gray'
          else 'no-type'

  }