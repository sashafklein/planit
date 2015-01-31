mod = angular.module('Models')
mod.factory 'ClusterLocator', (BasicOperators) ->

  class ClusterLocator

    @namesOrZoomForMore = (places) ->
      if places.length < 3
        BasicOperators.commaAndJoin( _(places).map('names').map((p) -> p[0]).value() )
      else
        'Zoom for more'

    @nearestGlobalRegion = (clusterLatLng) ->
      nearestRegion = ''
      nearestDistance = 100000000
      for globalRegion in @globalRegions()
        distanceToRegion = clusterLatLng.distanceTo(globalRegion.LatLng)
        if distanceToRegion < nearestDistance
          nearestDistance = distanceToRegion
          nearestRegion = globalRegion.name
      return nearestRegion

    @imageForLocation = (location) ->
      _(@globalRegions).select( (gr) -> location == gr.name ).value()[0].image

    @globalRegions = () ->
      [
        { name: 'The West Coast', LatLng: new L.LatLng('34.070862','-122.343750'), image: '' },
        { name: 'The Southwest', LatLng: new L.LatLng('37.770715','-114.257813'), image: '' },
        { name: 'The Pacific Northwest', LatLng: new L.LatLng('46.362093','-122.343750'), image: '' },
        { name: 'The East Coast', LatLng: new L.LatLng('39.147103','-76.640625'), image: '' },
        { name: 'The Southeast', LatLng: new L.LatLng('31.709476','-84.023438'), image: '' },
        { name: 'The Midwest', LatLng: new L.LatLng('41.294317','-87.890625'), image: '' },
        { name: 'The South', LatLng: new L.LatLng('30.202114','-94.218750'), image: '' },
        { name: 'North Africa', LatLng: new L.LatLng('27.430290','11.953125'), image: '' },
        { name: 'Middle East', LatLng: new L.LatLng('31.109389','36.210938'), image: '' },
        { name: 'Asian Steppe', LatLng: new L.LatLng('41.294317','65.742188'), image: '' },
        { name: 'South Asia', LatLng: new L.LatLng('22.978624','76.992188'), image: '' },
        { name: 'West Africa', LatLng: new L.LatLng('5.331644','-3.515625'), image: '' },
        { name: 'Central Africa', LatLng: new L.LatLng('1.472006','19.335938'), image: '' },
        { name: 'East Africa', LatLng: new L.LatLng('10.206813','37.617188'), image: '' },
        { name: 'Southern Africa', LatLng: new L.LatLng('-24.146754','24.960938'), image: '' },
        { name: 'South East Asia', LatLng: new L.LatLng('19.041349','99.843750'), image: '' },
        { name: 'Asian Pacific', LatLng: new L.LatLng('-0.637194','114.609375'), image: '' },
        { name: 'East Asia', LatLng: new L.LatLng('37.770715','129.726563'), image: '' },
        { name: 'Central Asia', LatLng: new L.LatLng('39.147103','90.000000'), image: '' },
        { name: 'The Baltic', LatLng: new L.LatLng('46.702202','35.507813'), image: '' },
        { name: 'Siberia', LatLng: new L.LatLng('61.013710','99.196656'), image: '' },
        { name: 'Eastern Europe', LatLng: new L.LatLng('48.596592','15.820313'), image: '' },
        { name: 'Western Europe', LatLng: new L.LatLng('47.323931','8.789063'), image: '' },
        { name: 'Great Britain', LatLng: new L.LatLng('54.406143','-5.273438'), image: '' },
        { name: 'Scandinavia', LatLng: new L.LatLng('65.099899','20.039063'), image: '' },
        { name: 'The Mediterranean', LatLng: new L.LatLng('40.229218','11.601563'), image: '' },
        { name: 'Latin America', LatLng: new L.LatLng('-1.340210','-65.742188'), image: '' },
        { name: 'South America', LatLng: new L.LatLng('-27.313214','-62.929688'), image: '' },
        { name: 'Central America', LatLng: new L.LatLng('12.618897','-86.835938'), image: '' },
        { name: 'South Pole', LatLng: new L.LatLng('-68.560384','-49.218750'), image: '' },
        { name: 'Pacific Islands', LatLng: new L.LatLng('-6.751896','146.250000'), image: '' },
        { name: 'Polar Circle', LatLng: new L.LatLng('70.699951','-101.250000'), image: '' },
        { name: 'Bering Sea', LatLng: new L.LatLng('63.665760','-165.937500'), image: '' },
      ]

  return ClusterLocator