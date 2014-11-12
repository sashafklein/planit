module Services
  class PlaceFinder

    attr_accessor :atts
    def initialize(atts)
      @atts = atts
    end

    def find!
      return nil unless sufficient_to_locate?

      place = Place.where.not( nil_exclusions ) 
                  .where(address_qualifiers)
                  .where( locality: atts[:locality] )
                  .with_address(atts[:street_addresses]).first || Place.new( place_atts )

      notify_and_round_out(place)
    end

    private

    def notify_and_round_out(place)
      if place.persisted?
        notify_of_merger_or_clash(place)
      else
        place
      end
    end

    def notify_of_merger_or_clash(place)
      if atts[:names].present? && place.name != atts[:names].first
        notify_of_name_clash(place)
        Place.new place_atts
      else
        notify_of_merger(place) 
        round_out(place)
      end
    end

    def sufficient_to_locate?
      (atts[:street_addresses].present? || atts[:names].present?) && 
        (atts[:locality] || atts[:region] || (atts[:lat] && atts[:lon]) || atts[:nearby])
    end

    def address_qualifiers
      atts.slice(:country, :region).select{ |k, v| v.present? }
    end

    def nil_exclusions
      address_finders.inject({}) { |c, k| c[k] = nil; c }
    end

    def address_finders
      [:street_addresses, :locality]
    end

    def place_atts
      atts.slice(*Place.attribute_keys)
    end

    def round_out(place)
      atts_to_update = place_atts.select { |k,v| should_update?(place, k) }
      new_names = ( place.names + place_atts.fetch(:names, []) ).compact.uniq
      new_phones = place_atts.fetch(:phones, {}).merge place.phones
      new_hours = place_atts.fetch(:hours, {}).merge place.hours

      place.update_attributes!(atts_to_update.merge({ names: new_names, phones: new_phones }))

      place
    end

    def should_update?(place, key)
      return false if [:names, :phones, :hours].include?(key)
      
      place_attr = place.read_attribute(key)
      place_attr != false && place_attr.blank?
    end

    def notify_of_merger(place)
      unless ENV['RAILS_ENV'] == 'test'
        PlaceMailer.delay.merger( place.id, diff(atts, place) )
      end
    end

    def notify_of_name_clash(place)
      unless ENV['RAILS_ENV'] == 'test'
        PlaceMailer.delay.name_clash( place.id, diff(atts, place) )
      end
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