angular.module("Common").directive 'bucketListClusters', (ClusterLocator) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "bucket_list_clusters.html"
    scope:
      cluster: '='
      map: '='
      padding: '='

    link: (s, element) ->

      s.cluster_places_ids = () ->
        return s._cluster_places_ids if s._cluster_places_ids
        s._cluster_places_ids = _(s.cluster.places).map('id').value()
      
      s.clusterZoom = (id) ->
        s.map.fitBounds( s.map._layers[ parseInt(id.split('c')[1]) ]._bounds , { paddingTopLeft: [s.padding[3], s.padding[0]], paddingBottomRight: [s.padding[1], s.padding[2]] } )

      s.clusterImage = (location) -> ClusterLocator.imageForLocation(location)
      s.pinsDetails = (places) -> ClusterLocator.pinsDetails(places)
        
  }
