module Services
  class PlaceFinder

    attr_accessor :atts, :search_atts
    def initialize(atts)
      @atts = atts
      @search_atts = atts.symbolize_keys.slice(:region, :country, :locality, :lat, :lon, :street_addresses, :names)
    end

    def find!
      return Place.new(search_atts) unless sufficient_to_locate?

      place = find_by_cascade
      place = notify_and_round_out(place)
      place
    end

    private

    def find_by_cascade
      place   = Place.by_location(search_atts).first
      place ||= find_by_ll_and_name
      place ||= Place.new( place_atts )

      place.persisted? ? place.merge(Place.new(place_atts)) : place
    end

    def notify_and_round_out(place)
      if place.persisted?
        notify_of_merger_or_clash(place)
      else
        place
      end
    end

    def notify_of_merger_or_clash(place)
      if search_atts[:names].present? && place.names.any?{ |name| !search_atts[:names].include?(name) }
        notify_of_name_clash(place)
        round_out(place)
      else
        notify_of_merger(place) 
        round_out(place)
      end
    end

    def find_by_ll_and_name
      Array(search_atts[:names]).each do |name|
        place = Place.by_ll_and_name(search_atts, name).first
        return place if place
      end
      nil
    end

    def sufficient_to_locate?
      (search_atts[:street_addresses].present? || search_atts[:names].present?) && 
        (search_atts[:locality] || search_atts[:region] || (search_atts[:lat] && search_atts[:lon]) || search_atts[:nearby])
    end

    def place_atts
      atts.slice(*Place.attribute_keys)
    end

    def round_out(place)
      place.assign_attributes( place_atts.select { |k,v| should_update?(place, k) } )
      
      place.names = ( place.names + place_atts.fetch(:names, []) ).compact.uniq
      place.phones = ( place.phones + place_atts.fetch(:phones, []) ).compact.uniq
      place.hours = place_atts.fetch(:hours, {}).merge place.hours

      place
    end

    def should_update?(place, key)
      return false if [:names, :phones, :hours].include?(key)
      
      place_attr = place.read_attribute(key)
      place_attr != false && place_attr.blank?
    end

    def notify_of_merger(place)
      place.add_flag("Place ##{place.id} merged with nonpersisted place. Added: #{additions(atts, place).to_s}")
    end

    def notify_of_name_clash(place)
      place.add_flag("Place ##{place.id} name clashed with nonpersisted place. Added: #{additions(atts, place).to_s}")
    end

    def additions(hash, object)
      result = {}
      atts = object.attributes.reject{ |k, v| %w(id updated_at created_at).include?(k) || v.blank? }
      atts.each do |key, object_val|
        hash_val = hash[key]
        result[key] = hash_val if hash_val != object_val && !hash_val.blank?
      end
      result.symbolize_keys
    end
  end
end