mod = angular.module('Models')
mod.factory 'ClusterLocator', (Place) ->

  class ClusterLocator

    @namesOrZoomForMore = (places) ->
      'Zoom for more'
      # if places.length < 4
      #   _(places).map('name()').value().join(', ')
      # else
      #   'Zoom for more'

    @lowestCommonArea = (places) -> Place.lowestCommonArea(places)

    @nearestGlobalRegion = (clusterLatLng) ->
      nearestRegion = ''
      nearestDistance = 100000000
      for globalRegion in @globalRegions()
        distanceToRegion = clusterLatLng.distanceTo(globalRegion.LatLng)
        if distanceToRegion < nearestDistance
          nearestDistance = distanceToRegion
          nearestRegion = globalRegion.name
      return nearestRegion

    @globalRegions = () ->
      [
        { name: 'Southwest', LatLng: new L.LatLng('34.070862','-116.718750') },
        { name: 'Pacific Northwest', LatLng: new L.LatLng('46.362093','-122.343750') },
        { name: 'East Coast', LatLng: new L.LatLng('36.650793','-77.343750') },
        { name: 'Midwest', LatLng: new L.LatLng('41.294317','-87.890625') },
        { name: 'North Africa', LatLng: new L.LatLng('27.430290','11.953125') },
        { name: 'Middle East', LatLng: new L.LatLng('31.109389','36.210938') },
        { name: 'Asian Steppe', LatLng: new L.LatLng('41.294317','65.742188') },
        { name: 'West Africa', LatLng: new L.LatLng('5.331644','-3.515625') },
        { name: 'Central Africa', LatLng: new L.LatLng('1.472006','19.335938') },
        { name: 'East Africa', LatLng: new L.LatLng('10.206813','37.617188') },
        { name: 'Southern Africa', LatLng: new L.LatLng('-24.146754','24.960938') },
        { name: 'South East Asia', LatLng: new L.LatLng('19.041349','99.843750') },
        { name: 'Asian Pacific', LatLng: new L.LatLng('-0.637194','114.609375') },
        { name: 'East Asia', LatLng: new L.LatLng('37.770715','129.726563') },
        { name: 'Central Asia', LatLng: new L.LatLng('39.147103','90.000000') },
        { name: 'Eastern Europe', LatLng: new L.LatLng('51.876491','30.234375') },
        { name: 'Western Europe', LatLng: new L.LatLng('47.323931','8.789063') },
        { name: 'Great Britain', LatLng: new L.LatLng('54.406143','-5.273438') },
        { name: 'Scandinavia', LatLng: new L.LatLng('65.099899','20.039063') },
        { name: 'Mediterranean', LatLng: new L.LatLng('40.229218','11.601563') },
        { name: 'South America', LatLng: new L.LatLng('21.227942','-60.117188') },
        { name: 'Central America', LatLng: new L.LatLng('12.618897','-86.835938') },
        { name: 'North America', LatLng: new L.LatLng('40.497092','-99.492188') },
        { name: 'South Pole', LatLng: new L.LatLng('-68.560384','-49.218750') },
      ]

  return ClusterLocator