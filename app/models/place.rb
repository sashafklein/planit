class Place < BaseModel

  has_one :item
  has_many :images, as: :imageable
  has_many :flags, as: :object

  array_accessor :completion_step, :street_address, :name, :category, :meta_category, :phone
  hstore_accessor :hours, :extra
  validate!

  delegate :open?, :open_again_at, :open_until, to: :hour_calculator

  extend PlaceQueries

  def tz; timezone_string; end

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

  def validate_and_save!(images=[], flags=[])
    PlaceSaver.new(self, images, flags).save!
  end

  def image
    images.first
  end

  def coordinate(joiner=':')
    lat && lon ? [lat, lon].join( joiner ) : false
  end

  def full
    [locality, country].reject(&:blank?).join(", ")
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
    names.drop(1)
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

  def tz_object
    Timezone::Zone.new({zone: tz})
  end

  def is?(meta_category)
    meta_categories.include?(meta_category.to_s)
  end

  def hour_calculator
    PlaceHours.new(hours, tz)
  end
end