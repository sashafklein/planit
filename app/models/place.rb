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
  scope :non_nil_pluck, -> (att) { where.not({att => nil}).order("#{att} ASC").pluck("DISTINCT #{att}") }

  def self.find_or_initialize(atts)
    Services::PlaceFinder.new(atts).find!
  end

  def self.center_coordinate(locations)
    [locations.average(:lat), locations.average(:lon)].join(":")
  end

  def self.countries
    non_nil_pluck(:country)
  end

  def self.regions
    non_nil_pluck(:region)
  end

  def self.localities
    non_nil_pluck(:locality)
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
    other = Place.find_or_initialize(attributes)

    return self unless other && other.persisted?

    other.merge(self)
    other
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
end
