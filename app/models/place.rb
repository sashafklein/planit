class Place < ActiveRecord::Base

  has_one :item
  has_many :images, as: :imageable
  
  include ActiveRecord::MetaExt
  array_accessor :flag, :completion_step, :street_address, :name, :category
  hstore_accessor :hours, :extra, :phones
  validate!

  scope :by_ll_and_name, -> (atts, name, points=2) { where.not( lat: nil ).where.not( lon: nil ).by_ll(atts[:lat], atts[:lon], points).with_name(name) }
  scope :by_location, -> (atts) { atts[:street_addresses].present? ? with_street_address.with_region_info(atts).with_street_address(atts[:street_addresses]) : none }
  scope :by_ll, -> (lat, lon, points=2) { by_lat(lat, points).by_lon(lon, points) }
  scope :by_lat, -> (lat, points) { lat && points ? where("ROUND( CAST(lat as numeric), ? ) = ?", points, lat.round(points) ) : none }
  scope :by_lon, -> (lon, points) { lon && points ? where("ROUND( CAST(lon as numeric), ? ) = ?", points, lon.round(points) ) : none }
  scope :with_region_info, -> (atts) { where( atts.slice(:country, :region, :locality).select{ |k, v| v.present? }.map{ |k, v| { k => v.no_accents } }.first )}

  delegate :open?, :open_again_at, :open_until, to: :hour_calculator

  def self.att_by_frequency(att)
    where.not(att => nil).select("#{att}, count(#{att}) as frequency").order('frequency desc').group(att).map(&att)
  end

  def self.find_or_initialize(atts)
    Services::PlaceFinder.new(atts).find!
  end

  def self.center_coordinate(locations)
    [locations.average(:lat), locations.average(:lon)].join(":")
  end

  def self.coordinates(place_joiner=':', coordinate_joiner='+')
    map{ |p| p.coordinate( place_joiner ) }.join coordinate_joiner
  end

  def validate_and_save!(images=[])
    PlaceSaver.new(self, images).save!
  end

  def image
    images.first
  end

  def coordinate(joiner=':')
    return false unless lat && lon
    [lat, lon].join( joiner )
  end

  def full
    string = ''
    string += locality.titleize unless locality.blank?
    string += country.titleize unless country.blank?
    string
  end

  def nearby
    return nil unless [locality, region, country].any?(&:present?)
    [locality, region, country].reject(&:blank?).join(", ")
  end

  def find_and_merge
    other = Place.find_or_initialize(attributes)

    return self unless other && other.persisted?

    other.merge(self)
    other
  end

  def alt_names
    array = names.drop(1)
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

  def timezone
    return @timezone if @timezone
    return @timezone = Timezone::Zone.new(zone: extra.timezone) if extra.timezone

    zone = Timezone::Zone.new({latlon: [lat, lon]})
    add_to_extra({ timezone: zone.zone })
    @timezone = zone
  end

  private

  def hour_calculator
    PlaceHours.new(hours, timezone.zone)
  end
end
