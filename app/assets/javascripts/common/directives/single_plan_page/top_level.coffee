angular.module("Common").directive 'topLevel', (ClassFromString) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_top_level.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.countries 
      s.regions
      s.localities

      s.planImage = ( plan ) -> plan?.best_image?.url?.replace("69x69","210x210")
      s.plansNoItems = -> s.m.lists?.length && !_.uniq( _.flatten( _.map( s.m.lists, (l) -> l.place_ids ) ) ).length

      s.folders = [ { type: "viewing", name: "GUIDES I RECENTLY VIEWED" }, { type: "home", name: "MY HOMETOWN GUIDES" }, { type: "travel", name: "MY TRAVEL GUIDES" } , { type: "followed", name: "GUIDES I'M FOLLOWING" } ]
      s.plansInFolder = ( folder ) -> _.sortBy( _.filter( s.m.plans , (p) -> p.typeOf() == folder.type ), (p) -> s.bestDate(p) )

      s.bestDate = ( plan ) -> if plan.starts_at then plan.starts_at else plan.updated_at

      s.tabClass = (plan, index) -> ClassFromString.toClass( plan.name, index )
        
      window.matrix = s
  }