angular.module("Directives").directive 'mobileExplore', (CountryJson) ->
  return { 
    restrict: 'E'
    replace: true
    templateUrl: 'single/tabs/_mobile_explore.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.$watch( 'm.view', (-> s.loadCountries() if s.m.view=='explore' ), true)
      s.loadCountries = ->
        return if s.m.currentPlanId || s.m.countries
        s.m.workingNow = true
        s.m.countries = {}
        _.forEach( CountryJson.json, (c) -> s.m.countries[ c['id'] ] = c )
        s.m.workingNow = false

      s.userClusters = -> 
        locations = s.m.locations
        return [] unless s.m.userInQuestionId && locations
        s.userClusterCertificate = "#{s.m.userInQuestionId}:#{_.map(locations, (l)-> l.geonameId).join('/')}"
        return s.lastUserClusters unless s.userClusterCertificate != s.lastUserClusterCertificate
        s.lastUserClusterCertificate = s.userClusterCertificate
        s.lastUserClusters = _.filter( locations, (l) -> _.include( l.users, s.m.userInQuestionId ) && l.isCluster )

      s.clustersCountry = ( cluster ) -> if cluster.countryName && cluster.clusterName != cluster.countryName then cluster.countryName

      s.setLocationToCluster = ( cluster ) -> s.m.currentLocationId = parseInt( cluster.geonameId ) if cluster?.geonameId

      window.mExplore = s

  }
