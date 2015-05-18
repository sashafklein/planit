angular.module("Common").directive 'userLocationPage', ($http, User) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_user_location_page.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.regions = -> _.uniq( _.compact( _.map( s.m.selectedCountryLocations(), (l) -> l.adminName1 ) ) )
      s.subRegions = ( regionName ) ->  _.uniq( _.compact( _.map( _.filter( s.m.selectedCountryLocations(), (l) -> l.adminName1 == regionName ), (l) -> l.adminName2 ) ) )
      s.populatedPlaces = ( subRegion ) -> _.filter( s.m.selectedCountryLocations(), (l) -> l.adminName2 == subRegion )

      window.countryscope = s
  }