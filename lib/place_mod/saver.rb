module PlaceMod
  class Saver

    attr_accessor :place, :images, :flags
    delegate :uniqify_array_attrs, :array_attrs_unique?, to: :place
    def initialize(place, images=[], flags=[])
      @place = place.persisted? ? place : place.class.new(place.attributes)
      @images, @flags = images, flags
    end

    def save!
      do_saving(true)
    end

    def save
      do_saving
    end

    def self.order_given_names(names)
      names = names.compact
      return names unless names.any?
      names.reject(&:non_latinate?) + names.select(&:non_latinate?).map(&:decode_characters)
    end

    def order_names
      place.names = self.class.order_given_names(place.names)
    end

    private

    def do_saving(raise_errors=false)
      format_phones
      format_categories
      supply_missing_street_address
      add_meta_categories
      order_names
      format_addresses
      uniqify_array_attrs
      correct_and_deaccent_regional_info
      format_hours
      set_timezone
      deduplicate_names
      set_locality_if_reasonable
      save_and_validate_changes!(raise_errors)
    end

    def save_and_validate_changes!(raise_errors=false)
      return false unless validate_changes(raise_errors)

      if (!place.persisted? && place.id) then sneaky_save! else @place.save! end

      save_images!
      save_flags!
      @place
    end

    def sneaky_save!
      preexisting = Place.find(place.id) 
      preexisting.update_attributes(place.attributes)
      @place = preexisting
    end

    def validate_changes(raise_errors=false)
      if !raise_errors 
        ( test_list.all? { |m| send(m) } ) ? true : false 
      else
        test_list.each{ |m| raise "Place Validation failed: #{m}" unless send(m) }
        true
      end
    end

    def test_list
      [:array_attrs_unique?, :regional_info_correct_and_deaccented?, :categories_capitalized?, 
        :hours_converted?, :timezone_set?, :phones_formatted?, :meta_categories_correct?, :names_ordered?]
    end

    def save_images!
      images.each do |photo|
        next if photo.exists?(place)
        photo.imageable = place
        photo.save_https!
      end
    end

    def save_flags!
      flags.each do |flag|
        next if place.flags.find_by(name: flag.name, details: flag.details)
        flag.update_attributes!(object_type: place.class.to_s, object_id: place.id)
      end
    end

    def expand_country
      place.country = Directories::AnglicizedCountry.find(place.country) || place.country
      if expand_country?
        carmen_country = Carmen::Country.coded(place.country)
        place.country = carmen_country.name if carmen_country
      end
    end

    def expand_region
      if expand_region? && carmen_country = Carmen::Country.named(place.country)
        carmen_region = carmen_country.subregions.try(:coded, place.region)
        place.region = carmen_region.name if carmen_region
      end
    end

    def correct_and_deaccent_regional_info
      place.country = place.country.no_accents if place.country_changed?
      place.region = place.region.no_accents if place.region_changed?
      place.subregion = place.subregion.no_accents if place.subregion_changed?
      place.locality = place.locality.no_accents if place.locality_changed?
      expand_country
      expand_region
    end

    def supply_missing_street_address
      place.street_addresses << place.full_address.split(",")[0].strip if place.street_address.blank? && place.full_address.is_defined?
    end

    def format_categories
      place.categories = place.categories.map(&:nuanced_titleize).map(&:no_accents)
    end

    def add_meta_categories
      place.meta_categories = CategorySet.new(place).set_meta_category
    end

    def meta_categories_correct?
      place.meta_categories.all?{ |mc| CategorySet::ALL_CATEGORIES.include?(mc) }
    end

    def expand_region?
      place.region_changed? && place.region && place.region.length < 3 
    end

    def expand_country?
      place.country_changed? && place.country && place.country.length < 3 
    end

    def regional_info_correct_and_deaccented?
      [:country, :region, :subregion, :locality].all? do |att|
        val = place.read_attribute(att)
        val.blank? || (!val.non_latinate? && val.length > 3)
      end
    end

    def categories_capitalized?
      place.categories.all?{ |c| c.capitalized? }
    end

    def format_hours
      place.set_hours Services::TimeConverter.convert_hours(place.hours)
    end

    def hours_converted?
      Services::TimeConverter.hours_converted?(place.hours)
    end

    def format_phones
      place.phones = place.phones.compact.map{ |v| v.gsub(%r!\D!, '') }.uniq
    end

    def phones_formatted?
      place.phones.all?{ |p| p.gsub(%r!\D!, '') == p } && (place.phones == place.phones.uniq)
    end

    def set_timezone
      place.timezone_string ||= Timezone::Zone.new({latlon: [place.lat, place.lon]}).zone
    end

    def timezone_set?
      place.timezone_string.present?
    end

    def names_ordered?
      return true if place.names.empty?
      !( place.names.first.non_latinate? && place.names.any?(&:latinate?) )
    end

    def format_addresses
      place.street_addresses = place.street_addresses.map{ |a| PlaceMod::Address.new(a).format }
      place.full_address = PlaceMod::Address.new( place.full_address ).format
    end

    def deduplicate_names
      new_names = []
      place.names.each do |name|
        previous = new_names.find{ |n| clean(n) == clean(name) }
        if previous
          if previous.length == name.length
            new_names[ new_names.index(previous) ] = ( [previous, name].sort{ |a, b| b.titlecase.match_distance(b) <=> a.titlecase.match_distance(a) }.first )
          else
            new_names[ new_names.index(previous) ] = [previous, name].max
          end
        else
          new_names << name
        end
      end
      place.names = new_names
    end

    def names_deduplicated?
      place.names.map(&:downcase).map(&:without_articles).uniq.count == place.names.count
    end

    def clean(name)
      name.downcase.without_articles(keep_first_word: true)
    end

    def remove_from_phones
      [' ', '-', String::LONG_DASH, '(', ')', '+']
    end

    def set_locality_if_reasonable
      if !place.locality && place.pinnable && (place.subregion || place.sublocality)
        replacement = place.subregion ? :subregion : :sublocality
        place.locality = place[replacement]
        place[ replacement ] = nil
      end
    end
  end
end