class Place < BaseModel

  has_one :item
  has_many :images, as: :imageable
  has_many :flags, as: :object

  array_accessor :completion_step, :street_address, :name, :category, :meta_category, :phone
  json_accessor :hours, :extra
  
  validates_presence_of :lat, :lon, :country, :names

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
    return nil unless [locality, subregion, region, country].any?(&:present?)
    [locality, subregion, region, country].reject(&:blank?).join(", ")
  end

  def find_and_merge
    other = Place.find_or_initialize(attributes)

    return self unless other && other.persisted?

    other.merge(self)
    other
  end

  def meta_icon
    if meta_categories
      return 'icomoon icon-map' if meta_categories[0] == 'Area'
      return 'icon-directions-walk' if meta_categories[0] == 'Do'
      return 'icon-local-bar' if meta_categories[0] == 'Drink'
      return 'icon-local-restaurant' if meta_categories[0] == 'Food'
      return 'fa fa-life-ring' if meta_categories[0] == 'Help'
      return 'fa fa-money' if meta_categories[0] == 'Money'
      return 'fa fa-globe' if meta_categories[0] == 'Other'
      return 'icon-drink' if meta_categories[0] == 'Relax'
      return 'fa fa-university' if meta_categories[0] == 'See'
      return 'fa fa-shopping-cart' if meta_categories[0] == 'Shop'
      return 'icon-home' if meta_categories[0] == 'Stay'
      if meta_categories[0] == 'Transit'
        if categories
          return 'fa fa-subway'
          return 'fa fa-plane'
          return 'fa fa-car'
          return 'fa fa-bus'
          return 'fa fa-train'
          return 'fa fa-taxi'
        else
          return 'fa fa-exchange'
        end
      end
    end
    return 'fa fa-globe'
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

  def other_info?
    result = if defined?(reservations) || price_tier.present? || price_note.present? || menu.present? || defined?(wifi) then true else false end
  end

  def has_sources?
    (foursquare_id) ? true : false # ADD OTHER || SOURCES
  end

  def foursquare_rating
    return false # REPLACE WHEN WE INTRODUCE TO DATABASE
  end
  def yelp_id
    return false # REPLACE WHEN WE INTRODUCE TO DATABASE
  end
  def yelp_rating
    return false # REPLACE WHEN WE INTRODUCE TO DATABASE
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