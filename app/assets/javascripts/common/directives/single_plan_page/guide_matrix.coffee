angular.module("Common").directive 'guideMatrix', () ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_guide_matrix.html'
    scope:
      m: '='
    link: (s, e, a) ->
      s.planImage = ( plan ) -> if plan && plan.best_image then plan.best_image.url else ''
      s.userOwns = (obj) -> s.m.currentUserId == obj.user_id
      s.plansNoItems = -> s.m.lists?.length && !_.uniq( _.flatten( _.map( s.m.lists, (l) -> l.place_ids ) ) ).length
  }