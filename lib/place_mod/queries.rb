module PlaceMod
  module Queries
    def with(*atts)
      nil_hash, blank_hash = [nil, ''].map{ |v| atts.inject({}){ |h, a| h[a] = v; h } }
      where.not( nil_hash ).where.not( blank_hash )
    end

    def by_ll_and_name(lat: nil, lon: nil, points: 2, names: [])
      with(:lat, :lon).by_ll(lat: lat, lon: lon, points: points).with_name(names) 
    end

    def by_location(street_addresses: nil, full_address: nil, region_info: {})
      return none unless full_address || street_addresses
      if street_addresses
        with_street_address.with_region_info(region_info).with_street_address(street_addresses) 
      else
        where( full_address: full_address )
      end
    end

    def by_ll(lat: nil, lon: nil, points: 2)
      by_lat(lat, points).by_lon(lon, points)
    end

    def by_lat(lat, points: 2)
      where("ROUND( CAST(lat as numeric), ? ) = ?", points, lat.round(points))
    end

    def by_lon(lon, points: 2)
      where("ROUND( CAST(lon as numeric), ? ) = ?", points, lon.round(points))
    end

    def with_region_info(region_atts)
      region_info = region_atts.to_sh.slice(:country, :region, :locality).select_val(&:present?).map_val(&:no_accents)
      where(region_info)
    end
  end
end