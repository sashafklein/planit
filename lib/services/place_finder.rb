module Services
  class PlaceFinder

    attr_accessor :atts
    def initialize(atts)
      @atts = atts
    end

    def find!
      return Place.new(atts) unless sufficient_to_locate?

      place = find_by_cascade
      place = notify_and_round_out(place)
      place
    end

    private

    def find_by_cascade
      place = Place.by_location(atts).first
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
      if atts[:names].present? && place.names.any?{ |name| !atts[:names].include?(name) }
        notify_of_name_clash(place)
        round_out(place)
      else
        notify_of_merger(place) 
        round_out(place)
      end
    end

    def find_by_ll_and_name
      Array(atts[:names]).each do |name|
        place = Place.by_ll_and_name(atts, name).first
        return place if place
      end
      nil
    end

    def sufficient_to_locate?
      (atts[:street_addresses].present? || atts[:names].present?) && 
        (atts[:locality] || atts[:region] || (atts[:lat] && atts[:lon]) || atts[:nearby])
    end

    def place_atts
      atts.slice(*Place.attribute_keys)
    end

    def round_out(place)
      place.assign_attributes( place_atts.select { |k,v| should_update?(place, k) } )
      
      place.names = ( place.names + place_atts.fetch(:names, []) ).compact.uniq
      place.phones = place_atts.fetch(:phones, {}).merge place.phones
      place.hours = place_atts.fetch(:hours, {}).merge place.hours

      place
    end

    def should_update?(place, key)
      return false if [:names, :phones, :hours].include?(key)
      
      place_attr = place.read_attribute(key)
      place_attr != false && place_attr.blank?
    end

    def notify_of_merger(place)
      return if ENV['RAILS_ENV'] == 'test'
      return
      PlaceMailer.delay.merger( place.id, diff(atts, place) )
    end

    def notify_of_name_clash(place)
      return if ENV['RAILS_ENV'] == 'test'
      return
      PlaceMailer.delay.name_clash( place.id, diff(atts, place) )
    end

    def diff(hash, object)
      result = {}
      atts = object.attributes.reject{ |k, v| %w(id updated_at created_at).include?(k) || v.blank? }
      atts.each do |key, object_val|
        hash_val = hash[key]
        result[key] = { object: object_val, hash: hash_val } if hash_val != object_val
      end
      result
    end
  end
end