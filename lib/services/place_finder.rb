module Services
  class PlaceFinder

    attr_accessor :atts, :search_atts, :query
    delegate :street_addresses, :names, :full_address, :lat, :lon, :region, :locality, :sublocality, :cross_street, :phones, :foursquare_id,
      to: :search_atts

    def initialize(atts)
      @atts = atts
      @search_atts = atts.to_sh.slice(:region, :country, :locality, :sublocality, :lat, :lon, :street_addresses, :names, :cross_street, :phones, :full_address, :foursquare_id).select_val(&:present?)
    end

    def find!(ll_points=3)
      return Place.new( place_atts ) unless names.present? || foursquare_id

      place   = Place.with(:foursquare_id).where(foursquare_id: foursquare_id).first if foursquare_id
      @query  = Place.with_name(names) if !place
      
      place ||= by_location
      place ||= by_lat_lon
      place ||= by_phones
      place ||= by_cross_street_and_region_info
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
      off_addresses = Array(street_addresses).flatten.any?{ |add|  place.street_addresses.any? { |pa| add.match_distance(pa).to_f < 0.8 } }
      off_cross_streets = cross_street.match_distance(place.cross_street).to_f < 0.8 if cross_street
      off_locality_or_sublocality = sublocality != place.sublocality || locality != place.locality

      if off_addresses || off_cross_streets || off_locality_or_sublocality
        place.flag(name: "Potentially problematic merge", details: "Place ##{place.id} merged with iffy data", info: clashes(incoming: atts, persisted: place))
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
      place.flag(name: "Name clash", details: "New name added to persisted place. New atts in info.", info: clashes(incoming: atts, persisted: place))
    end

    def by_location
      query.by_location(street_addresses: street_addresses, full_address: full_address, region_info: search_atts).first if street_addresses.present? || full_address
    end

    def by_lat_lon(points=3)
      query.by_lat(lat, points: points).by_lon(lon, points: points).first if lat && lon
    end

    def by_phones
      query.with_phone(phones).first if phones
    end

    def by_cross_street_and_region_info
      query.where(cross_street: cross_street).with_region_info(search_atts).first if cross_street
    end

    def clashes(incoming:, persisted:)
      incoming = incoming.symbolize_keys
      persisted = persisted.attributes.reject{ |k, v| %w(id updated_at created_at).include?(k) || v.blank? }.symbolize_keys

      disagreements = persisted.select do |key, persisted_val|
        incoming_val = incoming[key]
        incoming_val != persisted_val && !incoming_val.blank?
      end

      { persisted: persisted.slice( *disagreements.keys ), incoming: incoming.slice( *disagreements.keys ) }
    end

  end
end