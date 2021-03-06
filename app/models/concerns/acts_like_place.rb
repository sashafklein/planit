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
    images.where.not(url: nil).first
  end

  def coordinate(joiner=':')
    lat && lon ? [lat, lon].join( joiner ) : false
  end

  def tile_number( zoom )
    zoom ||= 15
    lat_rad = lat/180 * Math::PI
    n = 2.0 ** zoom
    x = ((lon + 180.0) / 360.0 * n).to_i
    y = ((1.0 - Math::log(Math::tan(lat_rad) + (1 / Math::cos(lat_rad))) / Math::PI) / 2.0 * n).to_i
   
    {:x => x, :y =>y}
  end

  def nearby
    list, final_list = [locality, subregion, region, country].select(&:present?), []
    return nil unless list.any?
    list.each_with_index do |item, index|
      # Reject items which appear to be redundant city-regions, eg "Municipality of Rome" as a subregion
      final_list << item unless item.include?(list[index]) && %w( Municip State Region Province Metrop ).any?{ |modifier| item.include?(modifier) || item.include?(modifier.downcase) }
    end
    final_list.uniq.join(", ")
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
    Source.where(obj_type: 'Mark', obj_id: Mark.where(place_id: id) )
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

  def background_complete!
    return if [locality, region, country, street_address].all?(&:present?) && ( images.count > 1 || completion_steps.include?("FoursquareRefine") )
    complete!
  end

  def complete!(delay: true)
    Completers::ExistingPlaceCompleter.new(self).complete!(delay: delay)
  end

  def address
    [street_address, sublocality].compact.join(", ") || object.full_address
  end

  def locale
    ([(locality || subregion), (region || country)]).compact.join(", ")
  end

  def altnames
    altnames = names.dup
    altnames.delete name
    altnames.length ? altnames : nil
  end

  private

  def tz_object
    Timezone::Zone.new({zone: tz})
  end

  def is?(meta_category)
    meta_categories.include?(meta_category.to_s)
  end

  def hour_calculator
    PlaceMod::Hours.new(hours, tz); rescue {}.to_sh
  end
end