module Services
  class PlaceFinder

    attr_accessor :atts, :search_atts, :query
    delegate :street_addresses, :names, :full_address, :lat, :lon, :region, :locality, :sublocality, :cross_street, :phones,
      to: :search_atts

    def initialize(atts)
      @atts = atts
      @search_atts = atts.to_sh.slice(:region, :country, :locality, :sublocality, :lat, :lon, :street_addresses, :names, :cross_street, :phones, :full_address).select_val(&:present?)
      @query = Place.query(search_atts).with_name(names)
    end

    def find!
      return Place.new( place_atts ) unless names.present?

      place   = query.by_lat.by_lon.relation.first if lat && lon
      place ||= query.by_location.relation.first if street_addresses.present? || full_address
      place ||= query.with_phone(phones).relation.first if phones
      place ||= query.where(cross_street: cross_street).with_region_info.relation.first if cross_street
      place ||= Place.new( place_atts )

      notify_and_round_out(place)
    end

    private

    def ll_and_name?
      search_atts.slice(:lat, :lon, :name).select_val(&:present?).any?
    end

    def notify_and_round_out(place)
      if place.persisted?
        notify_of_merger_or_clash(place)
      else
        place
      end
    end

    def notify_of_merger_or_clash(place)
      if names.present? && names.any?{ |name| !place.names.include?(name) }
        notify_of_name_clash(place)
        round_out(place)
      else
        notify_of_something_funny_if_funny(place)
        round_out(place)
      end
    end

    def notify_of_something_funny_if_funny(place)
      off_addresses = Array(street_addresses).flatten.any?{ |add|  place.street_addresses.any? { |pa| add.match_distance(pa) < 0.8 } }
      off_cross_streets = cross_street.match_distance(place.cross_street) < 0.8 if cross_street
      off_locality_or_sublocality = sublocality != place.sublocality || locality != place.locality

      if off_addresses || off_cross_streets || off_locality_or_sublocality
        place.add_flag("Place ##{place.id} merged with possibly problematic data. Possible clashes -- persisted: #{place.attributes.to_sh.slice(:street_addresses, :cross_street, :locality, :sublocality)}, incoming: #{search_atts.slice(:street_addresses, :cross_street, :locality, :sublocality)}}")
      end
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

    def notify_of_name_clash(place)
      place.add_flag("Place ##{place.id} name clashed with nonpersisted place. Added: #{additions(atts, place).to_s}")
    end
  end
end