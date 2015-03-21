mod = angular.module('Models')
mod.factory 'ClusterLocator', (BasicOperators) ->

  class ClusterLocator

    @pinsDetails = (places) ->
      types = _(places).map('meta_categories').flatten().uniq().value()
      # return types.join(' & ') + ' spots' if types.length < 3
      return 'pins'

    @nearestGlobalRegion = (clusterLatLng) ->
      nearestRegion = ''
      nearestDistance = 100000000
      for globalRegion in @globalRegions()
        distanceToRegion = clusterLatLng.distanceTo(globalRegion.LatLng)
        if distanceToRegion < nearestDistance
          nearestDistance = distanceToRegion
          nearestRegion = globalRegion.name
      return nearestRegion

    @imageForLocation = (location, places) ->
      image = _(@globalRegions()).select((g) -> if location == g.name then return g.image ).value()[0]
      unless image
        images = _.find(places, (p) -> p?.images?.length )?.images
        image = _.find(images, (i) -> i?.url?.length )?.url
      return image

    @globalRegions = () ->
      [
        { name: 'The West Coast', LatLng: new L.LatLng('34.070862','-122.343750'), image: false },
        { name: 'The Southwest', LatLng: new L.LatLng('37.770715','-114.257813'), image: false },
        { name: 'The Pacific Northwest', LatLng: new L.LatLng('46.362093','-122.343750'), image: false },
        { name: 'The East Coast', LatLng: new L.LatLng('39.147103','-76.640625'), image: false },
        { name: 'The Southeast', LatLng: new L.LatLng('31.709476','-84.023438'), image: false },
        { name: 'The Midwest', LatLng: new L.LatLng('41.294317','-87.890625'), image: false },
        { name: 'The South', LatLng: new L.LatLng('30.202114','-94.218750'), image: false },
        { name: 'Gulf of Mexico', LatLng: new L.LatLng('21.022983','-95.976563'), image: false },
        { name: 'North Africa', LatLng: new L.LatLng('27.430290','11.953125'), image: false },
        { name: 'Middle East', LatLng: new L.LatLng('31.109389','36.210938'), image: false },
        { name: 'Asian Steppe', LatLng: new L.LatLng('41.294317','65.742188'), image: false },
        { name: 'South Asia', LatLng: new L.LatLng('22.978624','76.992188'), image: false },
        { name: 'West Africa', LatLng: new L.LatLng('5.331644','-3.515625'), image: false },
        { name: 'Central Africa', LatLng: new L.LatLng('1.472006','19.335938'), image: false },
        { name: 'East Africa', LatLng: new L.LatLng('10.206813','37.617188'), image: false },
        { name: 'Southern Africa', LatLng: new L.LatLng('-24.146754','24.960938'), image: false },
        { name: 'South East Asia', LatLng: new L.LatLng('19.041349','99.843750'), image: false },
        { name: 'Asian Pacific', LatLng: new L.LatLng('-0.637194','114.609375'), image: false },
        { name: 'East Asia', LatLng: new L.LatLng('37.770715','129.726563'), image: false },
        { name: 'Central Asia', LatLng: new L.LatLng('39.147103','90.000000'), image: false },
        { name: 'The Baltic', LatLng: new L.LatLng('46.702202','35.507813'), image: false },
        { name: 'Siberia', LatLng: new L.LatLng('61.013710','99.196656'), image: false },
        { name: 'Eastern Europe', LatLng: new L.LatLng('48.596592','15.820313'), image: false },
        { name: 'Western Europe', LatLng: new L.LatLng('47.323931','8.789063'), image: false },
        { name: 'Great Britain', LatLng: new L.LatLng('54.406143','-5.273438'), image: false },
        { name: 'Scandinavia', LatLng: new L.LatLng('65.099899','20.039063'), image: false },
        { name: 'The Mediterranean', LatLng: new L.LatLng('40.229218','11.601563'), image: false },
        { name: 'Latin America', LatLng: new L.LatLng('-1.340210','-65.742188'), image: false },
        { name: 'South America', LatLng: new L.LatLng('-27.313214','-62.929688'), image: false },
        { name: 'Central America', LatLng: new L.LatLng('12.618897','-86.835938'), image: false },
        { name: 'South Pole', LatLng: new L.LatLng('-68.560384','-49.218750'), image: false },
        { name: 'Pacific Islands', LatLng: new L.LatLng('-6.751896','146.250000'), image: false },
        { name: 'Polar Circle', LatLng: new L.LatLng('70.699951','-101.250000'), image: false },
        { name: 'Bering Sea', LatLng: new L.LatLng('63.665760','-165.937500'), image: false },
      ]

  return ClusterLocator