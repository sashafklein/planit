angular.module("Common").directive 'bucketListPlaces', () ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "bucket_list_places.html"
    scope:
      place: '='
      # current_user: '='

    link: (s, element) ->

      # user_has(place_ids)
      #   place_ids = JSON.parse(place_ids)
      #   return true if _(current_user.marks.places.ids).contains(place_ids)
      #   return false

      # user_tags(place_ids)
      #   place_ids = JSON.parse(place_ids)
      #   if place_ids.length > 1 return only tags which all places include

      # user_loved(place_ids)
      #   place_ids = JSON.parse(place_ids)

      # user_been(place_ids)
      #   place_ids = JSON.parse(place_ids)
      
      # user_notes(place_ids)
      #   place_ids = JSON.parse(place_ids)

  }