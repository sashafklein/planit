angular.module("Common").directive 'bucketListClusters', (BucketEventManager, ClusterLocator, leafletData) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "bucket_list_clusters.html"
    scope:
      cluster: '='
      changes: '='
      zoomTo: '&'

    link: (s, element, attrs) ->

      s.latestChange = s.changes - 1

      s.clusterPlaceIds = ->
        return s._clusterPlaceIds if s._clusterPlaceIds
        if s._changeReady()
          s._clusterPlaceIds = _(s.cluster.places).map('id').value()
      
      s.clusterImage = () -> 

        return s.clusterImageIs if s.clusterImageIs
        if s._changeReady()
          s.clusterImageIs = ClusterLocator.imageForLocation(s.cluster.location, s.cluster.places)

      s.pinsDetails = () -> 
        return s.pinsDetailsAre if s.pinDetailsAre
        if s._changeReady()
          s.pinDetailsAre = ClusterLocator.pinsDetails(s.cluster.places)
      
      s._changeReady = ->
        if s.latestChange != s.changes
          s.latestChange++
          return true
        else
          return false
        
  }
