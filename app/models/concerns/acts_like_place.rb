module ActsLikePlace

  extend ActiveSupport::Concern

  class_methods do
    def att_by_frequency(att)
      where.not(att => nil).select("#{att}, count(#{att}) as frequency").order('frequency desc').group(att).map(&att)
    end

    def find_or_initialize(atts)
      PlaceMod::Finder.new(atts).find!
    end

    def center_coordinate(locations)
      [locations.average(:lat), locations.average(:lon)].join(":")
    end

    def coordinates(place_joiner=':', coordinate_joiner='+')
      map{ |p| p.coordinate( place_joiner ) }.join coordinate_joiner
    end
  end

  def tz; timezone_string; end

  def validate_and_save!(images=[], flags=[])
    PlaceMod::Saver.new(self, images, flags).save!
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
    list = [locality, subregion, region, country]
    return nil unless list.any?(&:present?)
    list.reject(&:blank?).uniq.join(", ")
  end

  def find_and_merge
    other = Place.find_or_initialize(attributes)

    return self unless other && other.persisted?

    other.merge(self)
    other
  end

  def meta_icon
    PlaceMod::MetaIcon.new(meta_category).icon
  end

  def alt_names
    names.drop(1)
  end

  def pinnable
    street_address || full_address || (lat && lon)
  end

  def not_in_usa?
    country.present? !country.in_usa?
  end

  def in_usa?
    ["United States", "United States of America"].include?(country)
  end

  def other_info?
    result = if defined?(reservations) || price_tier.present? || price_note.present? || menu.present? || defined?(wifi) then true else false end
  end

  def has_sources?
    (foursquare_id) ? true : false # ADD OTHER || SOURCES
  end

  def sources
    Source.where(object_type: 'Mark', object_id: Mark.where(place_id: id) )
  end

  def foursquare_rating
    false # REPLACE WHEN WE INTRODUCE TO DATABASE
  end
  
  def yelp_id
    false # REPLACE WHEN WE INTRODUCE TO DATABASE
  end
  
  def yelp_rating
    false # REPLACE WHEN WE INTRODUCE TO DATABASE
  end

  def tracking_data
    Flag.where(name: "Tracking Data").first
  end

  private

  def tz_object
    Timezone::Zone.new({zone: tz})
  end

  def is?(meta_category)
    meta_categories.include?(meta_category.to_s)
  end

  def hour_calculator
    PlaceMod::Hours.new(hours, tz)
  end
end