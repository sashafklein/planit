angular.module("Services").service "Distance", () ->

  class Distance

    KM: 6371 # km 
    MI: 3956 # mi

    @dLat: ( lat1, lat2 ) -> @toRad( lat2 - lat1 )
    @dLon: ( lon1, lon2 ) -> @toRad( lon2 - lon1 )
    @a: ( lat1, lon1, lat2, lon2 ) -> Math.sin( @dLat( lat2, lat1 ) / 2) * Math.sin( @dLat( lat2, lat1 ) / 2) + Math.cos( @toRad( lat1 ) ) * Math.cos( @toRad( lat2 ) ) * Math.sin( @dLon( lon1, lon2 ) / 2) * Math.sin( @dLon( lon1, lon2 ) / 2)
    @c: ( lat1, lon1, lat2, lon2 ) -> 2 * Math.atan2(Math.sqrt( @a( lat1, lon1, lat2, lon2 ) ), Math.sqrt(1 - @a( lat1, lon1, lat2, lon2 ) ))

    @miles: ( latLon1, latLon2 ) -> 
      return unless latLon1?.length = 2 && latLon2?.length = 2
      lat1 = parseFloat( latLon1[0] )
      lon1 = parseFloat( latLon1[1] )
      lat2 = parseFloat( latLon2[0] )
      lon2 = parseFloat( latLon2[1] )
      MI * @c( lat1, lon1, lat2, lon2 )

    @kilometers: ( latLon1, latLon2 ) -> 
      return unless latLon1?.length = 2 && latLon2?.length = 2
      lat1 = parseFloat( latLon1[0] )
      lon1 = parseFloat( latLon1[1] )
      lat2 = parseFloat( latLon2[0] )
      lon2 = parseFloat( latLon2[1] )
      KM * @c( lat1, lon1, lat2, lon2 )

    @toRad: (x) -> x * Math.PI / 180

  return Distance