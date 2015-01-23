class PlaceQuery

  attr_reader :search_atts, :relation
  delegate :names, :street_addresses, :locality, :lat, :lon, :subregion, :region, :country, :cross_street, :full_address,
           to: :search_atts

  def initialize(relation = Place.all, search_atts={})
    @relation = relation
    @search_atts = search_atts.to_sh
  end

  def with(*atts)
    nil_hash, blank_hash = [nil, ''].map{ |v| atts.inject({}){ |h, a| h[a] = v; h } }
    q where.not( nil_hash ).where.not( blank_hash )
  end

  def by_ll_and_name(points=2)
    q with(:lat, :lon).by_ll(points).with_name(names) 
  end

  def by_location
    if street_addresses.present?
      q with_street_address.with_region_info.with_street_address(street_addresses) 
    elsif full_address
      q where( full_address: full_address )
    else
      none
    end
  end

  def by_ll(points=2)
    q by_lat(points).by_lon(points)
  end

  def by_lat(points=2)
    return none unless lat && points
    q where("ROUND( CAST(lat as numeric), ? ) = ?", points, lat.round(points))
  end

  def by_lon(points=2)
    return none unless lon && points
    q where("ROUND( CAST(lon as numeric), ? ) = ?", points, lon.round(points))
  end

  def with_region_info
    region_info = search_atts.slice(:country, :region, :locality).select_val(&:present?).map_val(&:no_accents)
    q where(region_info)
  end

  def with_street_address(street_address=nil)
    q( street_address ? relation.with_street_address( street_address ) : relation.with_street_address )
  end

  def with_phone(phone=nil)
    q( phone ? relation.with_phone( phone ) : relation.with_phone )
  end

  def with_name(name=nil)
    q( name ? relation.with_name( name ) : relation.with_name )
  end

  def where(*conditions)
    q( relation.where(*conditions) )
  end

  def none(conditions)
    q relation.none
  end

  private
  
  def q(rel)
    self.class.new (rel.is_a?(PlaceQuery) ? rel.relation : rel) , search_atts
  end
end