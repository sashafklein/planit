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

    link: (s, element) ->

      s.clusterPlaceIds = ->
        return s._clusterPlaceIds if s._clusterPlaceIds
        console.log s.changes
        s._clusterPlaceIds = _(s.cluster.places).map('id').value()
      
      s.clusterImage = () -> 
        return s.clusterImageIs if s.clusterImageIs
        console.log s.changes
        s.slusterImageIs = ClusterLocator.imageForLocation(s.cluster.location, s.cluster.places)

      s.pinsDetails = () -> 
        return s.pinsDetailsAre if s.pinDetailsAre
        console.log s.changes
        s.pinDetailsAre = ClusterLocator.pinsDetails(s.cluster.places)

      # s._changeReady = ->
      #   s.latestChange = s.change unless s.latestChange
      #   if s.latestChange != s.change
      #     s.latestChange++
      #     return true
      #   else
      #     return false
        
  }
