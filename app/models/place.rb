class Place < ActiveRecord::Base

  before_save :uniqify_array_attrs
  before_save :deaccent_regional_info

  has_one :item
  has_many :images, as: :imageable
  
  include ActiveRecord::MetaExt
  validate!

  scope :with_nonempty_street_address, -> { where.not("street_addresses = '{}'") }
  scope :with_address, -> (address) { address.blank? ? all : where("'#{ address.is_a?(Array) ? address.first : address }' = ANY (street_addresses)") }
  scope :with_name, -> (name) { name.blank? ? all : where("? = ANY (names)", name.is_a?(Array) ? name.first : name) }
  scope :by_ll_and_name, -> (atts, name, points=2) { where.not( lat: nil ).where.not( lon: nil ).by_ll(atts[:lat], atts[:lon], points).with_name(name) }
  scope :by_location, -> (atts) { atts[:street_addresses].present? ? with_nonempty_street_address.with_region_info(atts).with_address(atts[:street_addresses]) : none }
  scope :by_ll, -> (lat, lon, points=2) { by_lat(lat, points).by_lon(lon, points) }
  scope :by_lat, -> (lat, points) { lat && points ? where("ROUND( CAST(lat as numeric), ? ) = ?", points, lat.round(points) ) : none }
  scope :by_lon, -> (lon, points) { lon && points ? where("ROUND( CAST(lon as numeric), ? ) = ?", points, lon.round(points) ) : none }
  scope :with_region_info, -> (atts) { where( atts.slice(:country, :region, :locality).select{ |k, v| v.present? }.map{ |k, v| { k => v.no_accents } }.first )}

  def self.find_or_initialize(atts)
    Services::PlaceFinder.new(atts).find!
  end

  def name
    names.first
  end

  def category
    categories.first
  end

  def street_address
    street_addresses.first
  end

  def self.center_coordinate(locations)
    [locations.average(:lat), locations.average(:lon)].join(":")
  end

  def coordinate(joiner=':')
    return false unless lat && lon
    [lat, lon].join( joiner )
  end

  def local_name_unique?
    return true unless name && local_name
    local_name.downcase != name.downcase
  end

  def full
    string = ''
    string += locality.titleize unless locality.blank?
    string += country.titleize unless country.blank?
    string
  end

  def nearby
    return @nearby if @nearby
    return nil unless [locality, region, country].any?(&:present?)
    @nearby ||= [locality, region, country].reject(&:blank?).join(", ")
  end

  def find_and_merge
    atts = attributes.symbolize_keys.slice(:region, :country, :locality, :lat, :lon, :street_address, :names)
    other = Place.find_or_initialize(atts)

    return self unless other && other.persisted?
    
    other.merge(self)
    other
  end

  def save_with_photos!(photos)
    return nil unless valid?

    save!

    Array(photos).each do |p| 
      next if images.find_by(url: p.url)
      p.update_attributes!(imageable_type: self.class.to_s, imageable_id: id)
    end
    
    self
  end

  def set_country(val)
    self.country = val
    expand_country
  end

  def set_region(val)
    self.region = val
    expand_region
  end

  private

  def expand_region
    if region_changed? && region.length < 3 && carmen_country = Carmen::Country.named(country)
      carmen_region = carmen_country.subregions.coded(region)
      self.region = carmen_region.name if carmen_region
    end
  end

  def expand_country
    if country_changed? && country.length < 3
      carmen_country = Carmen::Country.coded(country)
      self.country = carmen_country.name if carmen_country
    end
  end

  def deaccent_regional_info
    self.country = country.no_accents if country_changed?
    self.region = region.no_accents if region_changed?
    self.subregion = subregion.no_accents if subregion_changed?
    self.locality = locality.no_accents if locality_changed?
  end
end