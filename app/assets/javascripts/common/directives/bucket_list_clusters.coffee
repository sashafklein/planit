angular.module("Common").directive 'bucketListClusters', (BucketEventManager, ClusterLocator, leafletData) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "bucket_list_clusters.html"
    scope:
      map: '='
      cluster: '='
      padding: '='
      parentScope: '='

    link: (s, element) ->

      s.clusterLocator = ClusterLocator

      s.clusterZoom = ->
        leafletData.getMap().then (m) ->
          m.fitBounds( s.cluster.bounds , { paddingTopLeft: [s.padding[3], s.padding[0]], paddingBottomRight: [s.padding[1], s.padding[2]] } )
          new BucketEventManager(s.parentScope).deselectAll()

      s.clusterPlaceIds = ->
        return s._clusterPlaceIds if s._clusterPlaceIds
        s._clusterPlaceIds = _(s.cluster.places).map('id').value()
      
      s.clusterImage = () -> 
        return s.clusterImageIs if s.clusterImageIs
        s.slusterImageIs = s.clusterLocator.imageForLocation(s.cluster.location, s.cluster.places)

      s.pinsDetails = () -> 
        return s.pinsDetailsAre if s.pinDetailsAre
        s.pinDetailsAre = s.clusterLocator.pinsDetails(s.cluster.places)
        
  }
