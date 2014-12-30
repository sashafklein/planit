class Place < ActiveRecord::Base

  before_save :uniqify_array_attrs
  before_save :deaccent_regional_info
  before_save { self.categories.each(&:titleize) }

  has_one :item
  has_many :images, as: :imageable
  
  include ActiveRecord::MetaExt
  array_accessor :flag, :completion_step, :street_address, :name, :category
  hstore_accessor :hours, :extra
  validate!

  scope :by_ll_and_name, -> (atts, name, points=2) { where.not( lat: nil ).where.not( lon: nil ).by_ll(atts[:lat], atts[:lon], points).with_name(name) }
  scope :by_location, -> (atts) { atts[:street_addresses].present? ? with_street_address.with_region_info(atts).with_street_address(atts[:street_addresses]) : none }
  scope :by_ll, -> (lat, lon, points=2) { by_lat(lat, points).by_lon(lon, points) }
  scope :by_lat, -> (lat, points) { lat && points ? where("ROUND( CAST(lat as numeric), ? ) = ?", points, lat.round(points) ) : none }
  scope :by_lon, -> (lon, points) { lon && points ? where("ROUND( CAST(lon as numeric), ? ) = ?", points, lon.round(points) ) : none }
  scope :with_region_info, -> (atts) { where( atts.slice(:country, :region, :locality).select{ |k, v| v.present? }.map{ |k, v| { k => v.no_accents } }.first )}

  def self.find_or_initialize(atts)
    Services::PlaceFinder.new(atts).find!
  end

  def self.center_coordinate(locations)
    [locations.average(:lat), locations.average(:lon)].join(":")
  end

  def self.countries
    country_and_frequency = pluck(:country).compact.each_with_object(Hash.new(0)){ |m,h| h[m] += 1 }.sort {|a,b| b[1] <=> a[1]}
    country_and_frequency.map(&:first)
  end

  def self.regions
    region_and_frequency = pluck(:region).compact.each_with_object(Hash.new(0)){ |m,h| h[m] += 1 }.sort {|a,b| b[1] <=> a[1]}
    region_and_frequency.map(&:first)
  end

  def self.localities
    locality_and_frequency = pluck(:locality).compact.each_with_object(Hash.new(0)){ |m,h| h[m] += 1 }.sort {|a,b| b[1] <=> a[1]}
    locality_and_frequency.map(&:first)
  end

  def image
    images.first
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

    p = self.persisted? ? self : Place.new(attributes)
    p.save!

    Array(photos).each do |photo| 
      next if images.find_by(url: photo.url)
      photo.update_attributes!(imageable_type: p.class.to_s, imageable_id: p.id)
    end
    
    p
  end

  def set_country(val)
    self.country = Directories::AnglicizedCountry.find(val) || val
    expand_country
  end

  def set_region(val)
    self.region = val
    expand_region
  end

  def alt_names
    array = names.drop(1)
  end

  def open_until
    if hours.any?
      today = Date.today.strftime('%a').downcase
      # convert timezones, check if open, report back until when?
      if hours[today].scan(/end[_]time\=\>\"([^"]*)\"/).present?
        hours[today].scan(/end[_]time\=\>\"([^"]*)\"/).flatten.first
      end
    end
  end

  def open_again_at
    if hours.any?
      today = Date.today.strftime('%a').downcase
      # convert timezones, check if open, report back until when?
      if hours[today].scan(/start[_]time\=\>\"([^"]*)\"/).present?
        hours[today].scan(/start[_]time\=\>\"([^"]*)\"/).flatten.first
      end
    end
  end

  def pinnable
    street_address || full_address || (lat && lon)
  end

  def not_in_usa?
    country.present? && country != "United States" && country != "United States of America"
  end

  def in_usa?
    country == "United States" || country == "United States of America"
  end

  private

  def expand_region
    if region_changed? && region && region.length < 3 && carmen_country = Carmen::Country.named(country)
      carmen_region = carmen_country.subregions.coded(region)
      self.region = carmen_region.name if carmen_region
    end
  end

  def expand_country
    if country_changed? && country && country.length < 3
      carmen_country = Carmen::Country.coded(country)
      self.country = carmen_country.name if carmen_country
    end
  end

  def deaccent_regional_info
    self.country = country.no_accents if country_changed? && country
    self.region = region.no_accents if region_changed? && region
    self.subregion = subregion.no_accents if subregion_changed? && subregion
    self.locality = locality.no_accents if locality_changed? && locality
  end
end
